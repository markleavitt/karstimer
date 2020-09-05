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
  double colorSensAccel = 6.0;
  int distanceFilter = 3;
  int elapsedTime = 0;
  int currentLapNumber = 1;
  String elapsedTimeString = '00:00';
  String appVersion = "KarsTimer V?.?.?";
  Geolocator geolocator = Geolocator();
  final locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    // Using 0 gives timed 1 sec updates
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
      colorSensAccel = prefs.getDouble('colorSensAccel') ?? 6.0;
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
    lapStats.insert(
        0, _LapStats(currentLapNumber, elapsedTime, elapsedTimeString));
    _updateElapsedTime(reset: true);
    currentLapNumber++;
    notifyListeners();
  }

  void clearData() {
    racePositions = [];
    lapStats = [];
    lapMarkers = [{}, {}];
    currentLapNumber = 1;
    _updateElapsedTime(reset: true);
  }

  void setIsDarkTheme(bool setting) async {
    isDarkTheme = setting;
    await prefs.setBool('isDarkTheme', isDarkTheme);
  }

  void setIsAutoLapMark(bool setting) async {
    isAutoLapMark = setting;
    await prefs.setBool('isAutoLapMark', isAutoLapMark);
  }

  void setIsSimulatedData(bool setting) async {
    isSimulatedData = setting;
    await prefs.setBool('isSimulatedData', isSimulatedData);
  }

  void setIsTimedUpdates(bool setting) async {
    isTimedUpdates = setting;
    await prefs.setBool('isTimedUpdates', isTimedUpdates);
  }

  void setColorSensAccel(double setting) async {
    colorSensAccel = setting;
    await prefs.setIntDouble('colorSensAccel', colorSensAccel);
  }

  // Following methods are for internal use only
  void _updateElapsedTime({bool reset}) {
    if (!reset) {
      elapsedTime += intervalSecs;
      elapsedTimeString =
          '${(elapsedTime ~/ 60).toString().padLeft(2, '0')}:${(elapsedTime % 60).toString().padLeft(2, '0')}';
    } else {
      elapsedTime = 0;
      elapsedTimeString = '00:00';
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
    double previousSpeed = newPosition.speed;
    if (racePositions.length > 0) {
      previousPosition = racePositions.last;
      previousSpeed = racePositions.last.speed;
    }
    racePositions.add(newPosition);
    // Build marker for this position
    final newMarker = Marker(
      markerId: MarkerId(elapsedTimeString),
      icon: flagIcon,
      alpha: 0.25,
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
    // Add a polyline if there are at least 2 markers for this lap
    if (lapMarkers[currentLapNumber].length > 1) {
      polyLines[currentLapNumber][elapsedTimeString] = newPolyline;
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
