import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Create working instance of RaceData class for global use.
RaceData myRaceData = RaceData();

class RaceData extends ChangeNotifier {
  final int intervalSecs = 1; // Timer will tick 1x/sec
  bool isRunning = false;
  int elapsedTime = 0;
  int lapNumber = 0;
  String elapsedTimeString = '00:00';
  Geolocator geolocator = Geolocator();
  final locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // Experiment with distanceFilter under race conditions
  );

  StreamSubscription<Position> positionStreamSubscription;
  Position mapCenterPosition;
  Position startPosition;
  List<Position> positions = [];
  List<_LapStats> lapStats = [];
  Map<String, Marker> markers = {};

  Future<bool> initialize() async {
    // Checks Geolocator permissions, gets map center, returns true if OK
    try {
      GeolocationStatus geolocationStatus =
          await geolocator.checkGeolocationPermissionStatus();
      print('geoLocationStatus is: $geolocationStatus');
      mapCenterPosition = await geolocator.getCurrentPosition();
      return (geolocationStatus == GeolocationStatus.granted);
    } catch (e) {
      print('Geolocator error: $e');
      return false;
    }
  }

  void toggleState() {
    isRunning = !isRunning; // Toggle state of isRunning
    isRunning ? _start() : _stop(); // Call start or stop method
  }

  void markLap() {
    lapNumber++;
    lapStats.insert(0, _LapStats(lapNumber, elapsedTime, elapsedTimeString));
    _updateElapsedTime(reset: true);
    notifyListeners();
  }

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
    // Set up the periodic timer
    Timer.periodic(Duration(seconds: intervalSecs), (timer) {
      if (isRunning) {
        _updateElapsedTime(reset: false);
        notifyListeners();
        print('timer tick $elapsedTime');
      } else {
        timer.cancel();
        print('timer stopped');
      }
    });
    // Save starting position
    Position currentPosition = await geolocator.getCurrentPosition();
    startPosition = currentPosition;
    print('Starting position is: $currentPosition');
    // Now initiate the position stream subscription
    positionStreamSubscription =
        geolocator.getPositionStream(locationOptions).listen((position) {
      print('Position: $position, Speed: ${position.speed}');
      addPosition(position);
      notifyListeners();
    });

    print('positionStream subscription started');
    return true;
  }

  void addPosition(Position newPosition) {
    final newMarker = Marker(
      markerId: MarkerId(elapsedTimeString),
      position: LatLng(newPosition.latitude, newPosition.longitude),
      infoWindow: InfoWindow(
          title:
              'Lap: $lapNumber, ET: $elapsedTimeString, Speed: ${newPosition.speed.toStringAsFixed(1)}'),
    );
    markers[elapsedTimeString] = newMarker;
  }

  Future<void> _stop() async {
    isRunning = false;
    positionStreamSubscription.cancel();
    notifyListeners();
  }

// createDummyData is just used for testing
  void createDummyData() {}
}

class _LapStats {
  _LapStats(this.lapNumber, this.lapTime, this.lapTimeString);
  final int lapNumber;
  final int lapTime;
  final String lapTimeString;
}
