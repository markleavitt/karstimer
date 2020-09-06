import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

// Create working instance of RaceData class for global use.
RaceData myRaceData = RaceData();

class RaceData extends ChangeNotifier {
  final int intervalSecs = 1; // Timer will tick 1x/sec
  var prefs;
  bool isDarkTheme = false;
  bool isRunning = false;
  bool isAutoLapMark = false;
  bool isSimulatedData = false;
  bool isTimedUpdates = true;
  bool isShowMapFlags = true;
  double colorSensAccel = 6.0;
  int distanceFilter = 3;
  int elapsedTime = 0;
  int currentLapNumber = 1;
  int bestLapTime = 9999;
  int bestLapNumber;
  int minAcceptableLapTime = 0;
  int maxAcceptableLapTime = 600;
  String elapsedTimeString = '00:00';
  String lastLapTimeString = '  :  ';
  String bestLapTimeString = '  :  ';
  String appVersion = "KarsTimer V?.?.?";
  Geolocator geolocator = Geolocator();
  final locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
    timeInterval: 1000,
  );
  BitmapDescriptor flagIcon;

  StreamSubscription<Position> positionStreamSubscription;
  Position mapCenterPosition;
  Position startPosition;
  List<Position> racePositions = [];
  List<_LapStats> lapStats = [];
  List<Map<String, Marker>> lapMarkers = [{}, {}];
  List<Map<String, Polyline>> polyLines = [{}, {}];
  // Note: lapMarkers and polylines index corresponds to Lap Number, entry 0 is ignored

  Future<bool> initialize() async {
    try {
      // Get app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = 'KarsTimer V${packageInfo.version}';
      print(appVersion);
      // Get shared preferences stored on disk
      prefs = await SharedPreferences.getInstance();
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      isAutoLapMark = prefs.getBool('isAutoLapMark') ?? false;
      isSimulatedData = prefs.getBool('isSimulatedData') ?? false;
      isTimedUpdates = prefs.getBool('isTimedUpdates') ?? true;
      isShowMapFlags = prefs.getBool('isShowMapFlags') ?? true;
      colorSensAccel = prefs.getDouble('colorSensAccel') ?? 6.0;
      minAcceptableLapTime = prefs.getInt('minAcceptableLapTime') ?? 0;
      maxAcceptableLapTime = prefs.getInt('maxAcceptableLapTime') ?? 600;
      // Prepare the flagIcon for mapping
      flagIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), 'images/flag.png');
      // Check Geolocator permissions, get map center, return true if OK
      GeolocationStatus geolocationStatus =
          await geolocator.checkGeolocationPermissionStatus();
      print('Initial geoLocationStatus was: $geolocationStatus');
      mapCenterPosition = await geolocator.getCurrentPosition();
      return (geolocationStatus == GeolocationStatus.granted);
    } catch (e) {
      print('Geolocator error: $e');
      return false;
    }
  }

  void toggleState() {
    isRunning = !isRunning;
    isRunning ? _start() : _stop();
  }

  void markLap() {
    // Only save this lap data if within acceptable range
    if (elapsedTime >= minAcceptableLapTime &&
        elapsedTime <= maxAcceptableLapTime) {
      lapStats.insert(
          0, _LapStats(currentLapNumber, elapsedTime, elapsedTimeString));
      int lastLapTime = elapsedTime;
      lastLapTimeString = etToString(lastLapTime);
      if (lastLapTime < bestLapTime) {
        bestLapTime = lastLapTime;
        bestLapNumber = currentLapNumber;
        bestLapTimeString = etToString(bestLapTime);
      }
      currentLapNumber++;
    }
    // In any case, reset the elapsed time meter
    _updateElapsedTime(reset: true);
    notifyListeners();
  }

  void clearData() {
    racePositions = [];
    lapStats = [];
    lapMarkers = [{}, {}];
    polyLines = [{}, {}];
    currentLapNumber = 1;
    _updateElapsedTime(reset: true);
    lastLapTimeString = '  :  ';
    bestLapTimeString = '  :  ';
    bestLapTime = 9999;
  }

  void setIsDarkTheme(bool setting) async {
    isDarkTheme = setting;
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  void setIsAutoLapMark(bool setting) async {
    isAutoLapMark = setting;
    await prefs.setBool('isAutoLapMark', isAutoLapMark);
    notifyListeners();
  }

  void setIsSimulatedData(bool setting) async {
    isSimulatedData = setting;
    await prefs.setBool('isSimulatedData', isSimulatedData);
  }

  void setIsTimedUpdates(bool setting) async {
    isTimedUpdates = setting;
    await prefs.setBool('isTimedUpdates', isTimedUpdates);
  }

  void setIsShowMapFlags(bool setting) async {
    isShowMapFlags = setting;
    await prefs.setBool('isShowMapFlags', isShowMapFlags);
  }

  void setColorSensAccel(double setting) async {
    colorSensAccel = setting;
    await prefs.setDouble('colorSensAccel', colorSensAccel);
  }

  void setMinAcceptableLapTime(double setting) async {
    minAcceptableLapTime = setting.toInt();
    await prefs.setInt('minAcceptableLapTime', minAcceptableLapTime);
  }

  void setMaxAcceptableLapTime(double setting) async {
    maxAcceptableLapTime = setting.toInt();
    await prefs.setInt('maxAcceptableLapTime', maxAcceptableLapTime);
  }

  String etToString(int et) {
    return (et != null)
        ? '${(et ~/ 60).toString().padLeft(2, '0')}:${(et % 60).toString().padLeft(2, '0')}'
        : '  :  ';
  }

  // Following methods are for internal use only
  void _updateElapsedTime({bool reset}) {
    if (!reset) {
      elapsedTime += intervalSecs;
      elapsedTimeString = etToString(elapsedTime);
    } else {
      elapsedTime = 0;
      elapsedTimeString = etToString(elapsedTime);
    }
  }

  Future<bool> _start() async {
    isRunning = true;
    notifyListeners();
    // Get and save starting position
    startPosition = await geolocator.getCurrentPosition();
    print('Starting position is: $startPosition');
    // Start the periodic timer
    print('timer started');
    Timer.periodic(Duration(seconds: intervalSecs), (timer) {
      if (isRunning) {
        _updateElapsedTime(reset: false);
        if (isSimulatedData) {
          _addPosition(_simulateGPS(elapsedTime));
        }
        notifyListeners();
      } else {
        timer.cancel();
        print('timer stopped');
      }
    });
    // Configure locationUpdateOptions for timed (0) or distance
    final locationUpdateOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: (isTimedUpdates ? 0 : distanceFilter),
    );
    // Finally, start subscribing to the position stream
    if (!isSimulatedData) {
      positionStreamSubscription =
          geolocator.getPositionStream(locationUpdateOptions).listen((newPos) {
        _addPosition(newPos);
        notifyListeners();
      });
    }
    print(
        'GPS subscription started in ${isTimedUpdates ? 'timed' : 'distance'} mode');
    return true;
  }

  void _addPosition(Position newPosition) {
    // Save previous position and speed
    Position previousPosition = newPosition;
    if (racePositions.length > 0) {
      previousPosition = racePositions.last;
    }
    racePositions.add(newPosition);
    // Build marker for this position
    final newMarker = Marker(
      markerId: MarkerId(elapsedTimeString),
      icon: flagIcon,
      alpha: isShowMapFlags ? 0.25 : 0,
      position: LatLng(newPosition.latitude, newPosition.longitude),
      infoWindow: InfoWindow(
          title:
              'L:$currentLapNumber ET: $elapsedTimeString Spd: ${newPosition.speed.toStringAsFixed(0)} mph'),
    );
    // Calculate accel/decel and corresponding color
    double speedChange = (newPosition.speed - previousPosition.speed);
    double colorChange = 60.0 + colorSensAccel * speedChange;
    if (colorChange < 0.0) {
      colorChange = 0.0;
    }
    if (colorChange > 180.0) {
      colorChange = 180.0;
    }
    double colorValue = 0.5 + colorChange / 60.0;
    if (colorValue < 0) {
      colorValue = 0.0;
    }
    if (colorValue > 1.0) {
      colorValue = 1.0;
    }
    // Note that acceleration only computes if GPS updates are timed (not position based)
    Color speedColor =
        HSVColor.fromAHSV(1.0, colorChange, 1.0, colorValue).toColor();
    final newPolyline = Polyline(
      polylineId: PolylineId(elapsedTimeString),
      visible: true,
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      color: speedColor,
      points: [
        LatLng(previousPosition.latitude, previousPosition.longitude),
        LatLng(newPosition.latitude, newPosition.longitude),
      ],
    );
    // Add marker to map for this lap (note entry 0 in list is not used)
    while (currentLapNumber > lapMarkers.length - 1) {
      lapMarkers.add({}); // Add an empty lapMarkers map for this lap
      polyLines.add({}); // Add empty polyLines map for this lap
    }
    lapMarkers[currentLapNumber][elapsedTimeString] = newMarker;
    polyLines[currentLapNumber][elapsedTimeString] = newPolyline;
    // Check for automatic lap crossings
    if (isAutoLapMark) {
      checkLapCrossing(previousPosition, newPosition);
    }
  }

  void checkLapCrossing(Position p1, Position p2) async {
    const double maxRange = 100.0; // Meters distance
    const double minRange = 10.0; // Meters distance
    // If this lap has just started, go no further
    if (lapMarkers[currentLapNumber].length < 10) {
      return;
    }
    // Calculate distance from start point to previous and current point
    final double distanceToP1 = await geolocator.distanceBetween(
        startPosition.latitude,
        startPosition.longitude,
        p1.latitude,
        p1.longitude);
    final double distanceToP2 = await geolocator.distanceBetween(
        startPosition.latitude,
        startPosition.longitude,
        p2.latitude,
        p2.longitude);
    // If neither location is within range of the start point, no need to proceed further
    if (distanceToP1 > maxRange && distanceToP2 > maxRange) {
      return;
    }
    // If newest position is very near the start point, declare a new lap and return
    if (distanceToP2 < minRange) {
      print('Lap completed by being in close range to starting point');
      markLap();
      return;
    }
    // At least one point is in range, so continue the calculation with bearings
    final double bearingToP1 = await geolocator.bearingBetween(
        startPosition.latitude,
        startPosition.longitude,
        p1.latitude,
        p1.longitude);
    final double bearingToP2 = await geolocator.bearingBetween(
        startPosition.latitude,
        startPosition.longitude,
        p2.latitude,
        p2.longitude);
    // If points are in opposite directions from start point, mark the lap
    if ((bearingToP1 - bearingToP2).abs() % 360.0 > 120) {
      print('Lap completed by sweeping past starting point');
      markLap();
    }
  }

  Future<void> _stop() async {
    isRunning = false; // This will stop the timer at the next tick
    if (positionStreamSubscription != null) {
      positionStreamSubscription.cancel();
    }
    notifyListeners();
  }

  Position _simulateGPS(int eTime) {
    // Simulates an elliptical path which passes through the start point
    const double minorAxis =
        0.001; // Track ellipse minor axis in degrees latitude
    const double majorAxis =
        0.0025; // Track ellipse major axis in deg longitude
    const double degPerSec = 12.0; // Degrees around the ellipse per second
    double deg2rad = pi / 180.0;
    double t = eTime.toDouble();
    // Create an elliptical trajectory with speed variation too
    double x = sin(t * degPerSec * deg2rad);
    double y =
        1 - cos(t * degPerSec * deg2rad); // Start at bottom center, go CCW
    double s = 80.0 + 20.0 * cos(t * 2.0 * degPerSec * deg2rad);
    double lat = startPosition.latitude + minorAxis * y;
    double long = startPosition.longitude + majorAxis * x;
    Position simPosition = Position(
        latitude: lat, longitude: long, timestamp: DateTime.now(), speed: s);
    return simPosition;
  }
}

class _LapStats {
  _LapStats(this.lapNumber, this.lapTime, this.lapTimeString);
  final int lapNumber;
  final int lapTime;
  final String lapTimeString;
}
