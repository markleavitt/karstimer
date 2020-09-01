import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Create working instance of RaceData class for global use.
RaceData myRaceData = RaceData();

class RaceData extends ChangeNotifier {
  final int intervalSecs = 1;
  bool isRunning = false;
  int elapsedTime = 0;
  String elapsedTimeString = '00:00';
  Geolocator geolocator = Geolocator();
  StreamSubscription<Position> positionStreamSubscription;
  Position startPosition;
  List<Position> positions = [];
  List<Widget> positionWidgets = [];
  List<_lapTimes> lapTimes = [];

  Future<bool> initialize() async {
    // Checks permission status of Geolocator, returns true if all OK
    try {
      GeolocationStatus geolocationStatus =
          await geolocator.checkGeolocationPermissionStatus();
      print('geoLocationStatus is: $geolocationStatus');
      return (geolocationStatus == GeolocationStatus.granted);
    } catch (e) {
      print('Geolocator error: $e');
      return false;
    }
  }

  void toggleState() {
    if (isRunning) {
      stop();
    } else {
      start();
    }
  }

  void _updateElapsedTime(bool reset) {
    if (!reset) {
      elapsedTime += intervalSecs;
      elapsedTimeString =
          '${(elapsedTime ~/ 60).toString().padLeft(2, '0')}:${(elapsedTime % 60).toString().padLeft(2, '0')}';
    } else {
      elapsedTime = 0;
      elapsedTimeString = '00:00';
    }
  }

  Future<bool> start() async {
    isRunning = true;
    _updateElapsedTime(true);
    notifyListeners();
    print('timer started');
    // Set up the periodic timer
    Timer.periodic(Duration(seconds: intervalSecs), (timer) {
      if (isRunning) {
        _updateElapsedTime(false);
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
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    positionStreamSubscription = geolocator
        .getPositionStream(locationOptions)
        .listen((Position thisPosition) {
      print(thisPosition);
    });

    print('positionStream subscription started');
    return true;
  }

  Future<void> stop() async {
    isRunning = false;
    positionStreamSubscription?.cancel();
    notifyListeners();
  }

// createDummyData is just used for testing
  void createDummyData() {}
}

class _lapTimes {
  int lapNumber;
  int lapTime;
}
