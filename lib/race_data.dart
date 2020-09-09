import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karstimer/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

// Create working instance of RaceData class for global use.
RaceData myRaceData = RaceData();

class RaceData extends ChangeNotifier {
  final int intervalSecs = 1; // Timer will tick 1x/sec
  var prefs;
  // These are the preference variables
  bool isDarkTheme = false;
  bool isAutoLapMark = false;
  bool isSimulatedData = false;
  bool isShowMapFlags = true;
  int minAcceptableLapTime = 0;
  int maxAcceptableLapTime = 600;
  double colorSensAccel = 6.0;
  // Status variables
  bool isRunning = false;
  String locationAccuracy = 'Not ready';
  String lastLapTrigger = "None";
  int elapsedTime = 0;
  int currentLapNumber = 1;
  int bestLapTime = 9999;
  int bestLapNumber;
  double currentSpeedMph = 0;
  double lapTopSpeedMph = 0;
  String elapsedTimeString = '00:00';
  String lastLapTimeString = '  :  ';
  String bestLapTimeString = '  :  ';
  String appVersion = "KarsTimer V?.?.?";
  // Geolocator object, options, and stream
  Geolocator geolocator = Geolocator();
  final locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    timeInterval: 1000,
  );
  StreamSubscription<Position> positionStreamSubscription;
  // Data from the race
  List<Position> racePositions =
      []; // Includes time, latlng, speed, accuracy, etc
  List<_LapStats> lapStats = []; // Laps are inserted at 0 so order is reversed
  // Map making data
  BitmapDescriptor flagIcon;
  Position startPosition;
  Position mapCenterPosition;
  List<Map<String, Marker>> lapMarkers = [{}, {}];
  List<Map<String, Polyline>> polyLines = [{}, {}];
  // Note: lapMarkers and polylines index corresponds to Lap Number, entry 0 is ignored

  Future<void> initialize() async {
    // Get app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = 'KarsTimer V${packageInfo.version}';
    print(appVersion);
    // Get shared preferences stored on disk
    prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    isAutoLapMark = prefs.getBool('isAutoLapMark') ?? false;
    isSimulatedData = prefs.getBool('isSimulatedData') ?? false;
    isShowMapFlags = prefs.getBool('isShowMapFlags') ?? true;
    colorSensAccel = prefs.getDouble('colorSensAccel') ?? 6.0;
    minAcceptableLapTime = prefs.getInt('minAcceptableLapTime') ?? 0;
    maxAcceptableLapTime = prefs.getInt('maxAcceptableLapTime') ?? 600;
    // Prepare the flagIcon for mapping
    flagIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/flag.png');
    // Get current position to center map (this will also request permission)
    mapCenterPosition = await geolocator.getCurrentPosition();
    print('Got map center position');
    GeolocationStatus geoLocationStatus =
        await geolocator.checkGeolocationPermissionStatus();
    print('Location status: $geoLocationStatus');
    // Now subscribe to the position stream if not using simulator
    if (!isSimulatedData) {
      _gpsSubscribe(turnOn: true);
    }
  }

  void toggleState() {
    isRunning = !isRunning;
    isRunning ? _startRace() : _stop();
  }

  void markLap() {
    // Only save this lap data if within acceptable range
    if (elapsedTime >= minAcceptableLapTime &&
        elapsedTime <= maxAcceptableLapTime) {
      lapStats.insert(
          0,
          _LapStats(currentLapNumber, lapTopSpeedMph, elapsedTime,
              elapsedTimeString));
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

  void clearStartingPosition() {
    startPosition = null;
  }

  void saveData(BuildContext context) async {
    // Prepare current timestamp and get external directory path
    final DateTime nowDate = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd–kk-mm').format(nowDate);
    final externalDirectory = await getExternalStorageDirectory();

    final raceDataFile =
        File('${externalDirectory.path}/RaceData-$formattedDate.csv');
    print('Saving RaceData to $raceDataFile');
    String raceDataString = 'TimeStamp, Latitude, Longitude, Accuracy, Speed\n';
    for (Position record in racePositions) {
      raceDataString +=
          '${record.timestamp}, ${record.latitude}, ${record.longitude}, ${record.accuracy}, ${record.speed}\n';
    }
    await raceDataFile.writeAsString(raceDataString);
    //String raceDataReadBack = await raceDataFile.readAsString();

    final lapDataFile =
        File('${externalDirectory.path}/LapData-$formattedDate.csv');
    print('Saving LapData to $lapDataFile');
    String lapDataString = 'Lap Number, Lap Time, Top Speed (mph)\n';
    for (_LapStats record in lapStats) {
      lapDataString +=
          '${record.lapNumber}, ${record.lapTime}, ${record.lapTopSpeed}\n';
    }
    await lapDataFile.writeAsString(lapDataString);
    //String lapDataReadBack = await lapDataFile.readAsString();
    // Clear existing data
    eraseData();
    // Display a message confirming data saved
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          'Data Saved\n\nMemory Erased',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
          ),
        ),
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void eraseData() {
    startPosition = null;
    racePositions = [];
    lapStats = [];
    lapMarkers = [{}, {}];
    polyLines = [{}, {}];
    currentLapNumber = 1;
    locationAccuracy = 'unknown';
    lastLapTrigger = 'none';
    _updateElapsedTime(reset: true);
    lastLapTimeString = '  :  ';
    bestLapTimeString = '  :  ';
    bestLapTime = 9999;
    currentSpeedMph = 0;
    lapTopSpeedMph = 0;
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
    if (isSimulatedData) {
      _gpsSubscribe(turnOn: false);
    } else {
      _gpsSubscribe(turnOn: true);
    }
    notifyListeners();
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
      lapTopSpeedMph = 0;
    }
  }

  Future<bool> _startRace() async {
    isRunning = true;
    notifyListeners();
    // If no previous starting position, record current position as start
    if (startPosition == null) {
      startPosition = await geolocator.getCurrentPosition();
      print('Starting position is: $startPosition');
    }
    // Start the periodic timer
    print('timer started');
    Timer.periodic(Duration(seconds: intervalSecs), (timer) {
      if (isRunning) {
        _updateElapsedTime(reset: false);
        if (isSimulatedData) {
          _processPositionUpdate(_simulateGPS(elapsedTime));
        }
        notifyListeners();
      } else {
        timer.cancel();
        print('timer stopped');
      }
    });
    return true;
  }

  void _gpsSubscribe({bool turnOn}) async {
    if (turnOn) {
      if (positionStreamSubscription == null) {
        positionStreamSubscription =
            geolocator.getPositionStream(locationOptions).listen((newPos) {
          _processPositionUpdate(newPos);
        });
        print('Subscribed to GPS stream');
      }
    } else {
      if (positionStreamSubscription != null) {
        await positionStreamSubscription.cancel();
        positionStreamSubscription = null;
        print('GPS subscription cancelled');
      }
    }
  }

  void _processPositionUpdate(Position newPosition) {
    // Save the accuracy for display
    if (isSimulatedData) {
      locationAccuracy = '(simulated 50 m)';
    } else {
      locationAccuracy = (newPosition.accuracy != null)
          ? '${newPosition.accuracy.toStringAsFixed(0)} m'
          : "unknown";
    }
    notifyListeners();
    if (!isRunning) {
      return;
    }
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
              'L:$currentLapNumber ET: $elapsedTimeString Spd: ${(newPosition.speed * mpsToMph).toStringAsFixed(0)} mph'),
    );
    // Convert speed to mph and record top speed for this lap
    currentSpeedMph = newPosition.speed * mpsToMph;
    if (currentSpeedMph > lapTopSpeedMph) {
      lapTopSpeedMph = currentSpeedMph;
    }
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
    // If this is a new lap, add array element for lapMarkers and polyLines
    while (currentLapNumber > lapMarkers.length - 1) {
      lapMarkers.add({}); // Add an empty lapMarkers map for this lap
      polyLines.add({}); // Add empty polyLines map for this lap
    }
    // If this is first entry on this lap, add the starting marker
    if (lapMarkers[currentLapNumber].isEmpty) {
      final startingMarker = Marker(
        markerId: MarkerId('START'),
        icon: BitmapDescriptor.defaultMarkerWithHue(180),
        alpha: 1.0,
        position: LatLng(startPosition.latitude, startPosition.longitude),
        infoWindow: InfoWindow(title: 'L:$currentLapNumber START'),
      );
      lapMarkers[currentLapNumber]['START'] = startingMarker;
    }
    // Finally, add the new point
    lapMarkers[currentLapNumber][elapsedTimeString] = newMarker;
    polyLines[currentLapNumber][elapsedTimeString] = newPolyline;

    // Check for automatic lap crossings
    if (isAutoLapMark) {
      _checkLapCrossing(previousPosition, newPosition);
    }
    notifyListeners();
  }

  void _checkLapCrossing(Position p1, Position p2) async {
    const double maxRange = 100.0; // Meters distance
    const double minRange = 10.0; // Meters distance
    // If this lap has just started, go no further
    if (lapMarkers[currentLapNumber].length < 10) {
      return;
    }
    // If not moving, go no further
    if (currentSpeedMph < 1) {
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
      lastLapTrigger = 'proximity of ${distanceToP2.toStringAsFixed(0)} m';
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
    // Calculate raw angle between bearings (discard sign)
    double rawAngle = (bearingToP1 - bearingToP2).abs();
    // Correct for angles > 180
    double correctedAngle = (rawAngle <= 180.0) ? rawAngle : 360.0 - rawAngle;
    if (correctedAngle > 90.0) {
      lastLapTrigger =
          'bearing swing of ${correctedAngle.toStringAsFixed(0)} deg';
      markLap();
    }
  }

  Future<void> _stop() async {
    isRunning = false; // This will stop the timer at the next tick
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
    // Create an elliptical trajectory
    double x = sin(t * degPerSec * deg2rad);
    double y =
        1 - cos(t * degPerSec * deg2rad); // Start at bottom center, go CCW
    // Create speed in meters per second
    double mps = 40.0 + 10.0 * cos(t * 2.0 * degPerSec * deg2rad);
    // Create lat/long and inject 10% noise
    double lat = startPosition.latitude +
        minorAxis * y +
        minorAxis * 0.05 * Random().nextDouble();
    double long = startPosition.longitude +
        majorAxis * x +
        majorAxis * 0.05 * Random().nextDouble();
    Position simPosition = Position(
      latitude: lat,
      longitude: long,
      timestamp: DateTime.now(),
      accuracy: 50,
      speed: mps,
    );
    return simPosition;
  }
}

class _LapStats {
  _LapStats(this.lapNumber, this.lapTopSpeed, this.lapTime, this.lapTimeString);
  final int lapNumber;
  final double lapTopSpeed;
  final int lapTime;
  final String lapTimeString;
}
