import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create working instance of RaceData class for global use.
RaceData myRaceData = RaceData();

class RaceData extends ChangeNotifier {
  final int intervalSecs = 1; // Timer will tick 1x/sec
  var prefs;
  bool isRunning = false;
  bool isAutoLapMark = false;
  bool isSimulatedData = false;
  bool isTimedUpdates = true;
  int distanceFilter = 3;
  int elapsedTime = 0;
  int currentLapNumber = 1;
  String elapsedTimeString = '00:00';
  Geolocator geolocator = Geolocator();
  final locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    // Can experiment with distanceFilter under race conditions
    // Using 0 gives timed 1 sec updates
  );

  StreamSubscription<Position> positionStreamSubscription;
  Position mapCenterPosition;
  Position startPosition;
  List<Position> racePositions = [];
  List<_LapStats> lapStats = [];
  List<Map<String, Marker>> lapMarkers = [{}, {}];
  // Note: lapMarkers index corresponds to Lap Number, entry 0 is ignored

  Future<bool> initialize() async {
    try {
      // Check Geolocator permissions, get map center, return true if OK
      GeolocationStatus geolocationStatus =
          await geolocator.checkGeolocationPermissionStatus();
      print('Initial geoLocationStatus was: $geolocationStatus');
      mapCenterPosition = await geolocator.getCurrentPosition();
      // Get shared preferences stored on disk
      prefs = await SharedPreferences.getInstance();
      isAutoLapMark = prefs.getBool('isAutoLapMark') ?? false;
      isSimulatedData = prefs.getBool('isSimulatedData') ?? false;
      isTimedUpdates = prefs.getBool('isTimedUpdates') ?? true;
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

  void createDummyData() {
    // TODO need mock GPS creation method
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
    _updateElapsedTime(reset: true);
    notifyListeners();
    print('timer started');
    // Start the periodic timer
    Timer.periodic(Duration(seconds: intervalSecs), (timer) {
      if (isRunning) {
        _updateElapsedTime(reset: false);
        notifyListeners();
      } else {
        timer.cancel();
        print('timer stopped');
      }
    });
    // Save starting position
    Position currentPosition = await geolocator.getCurrentPosition();
    startPosition = currentPosition;
    print('Starting position is: $currentPosition');
    // Now start the position stream subscription
    final locationUpdateOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: (isTimedUpdates ? 0 : distanceFilter),
    );
    positionStreamSubscription =
        geolocator.getPositionStream(locationUpdateOptions).listen((newPos) {
      _addPosition(newPos);
      notifyListeners();
    });
    print('positionStream subscription started');
    return true;
  }

  void _addPosition(Position newPosition) {
    // Add to overall race data
    racePositions.add(newPosition);
    // Build marker for this position
    final newMarker = Marker(
      markerId: MarkerId(elapsedTimeString),
      position: LatLng(newPosition.latitude, newPosition.longitude),
      infoWindow: InfoWindow(
          title:
              'L:$currentLapNumber ET: $elapsedTimeString Spd: ${newPosition.speed.toStringAsFixed(0)} mph'),
    );
    // Add marker to map for this lap (note entry 0 in list is not used)
    while (currentLapNumber > lapMarkers.length - 1) {
      lapMarkers.add({}); // Add an empty map for this lap
    }
    lapMarkers[currentLapNumber][elapsedTimeString] = newMarker;
  }

  Future<void> _stop() async {
    isRunning = false;
    positionStreamSubscription.cancel();
    notifyListeners();
  }
}

class _LapStats {
  _LapStats(this.lapNumber, this.lapTime, this.lapTimeString);
  final int lapNumber;
  final int lapTime;
  final String lapTimeString;
}
