import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

RaceData myRaceData = RaceData();

class RaceData extends ChangeNotifier {
  bool isRunning = false;
  int elapsedTime = 0;
  String elapsedTimeString = '00:00';
  var geolocator = Geolocator();
  Stream<Position> positionStream;
  List<Position> positions = [];
  List<Widget> positionWidgets = [];
  List<_lapTimes> lapTimes = [];
  int lapCount() => lapTimes.length;
  int positionsCount() => positions.length;

  Future<bool> checkStatus() async {
    GeolocationStatus geolocationStatus =
        await geolocator.checkGeolocationPermissionStatus();
    print('geoLocationStatus is: $geolocationStatus');
    return (geolocationStatus == GeolocationStatus.granted);
  }

  void toggleState() {
    if (isRunning) {
      stop();
    } else {
      start();
    }
  }

  void updateElapsedTime(bool reset) {
    if (!reset) {
      elapsedTime++;
      elapsedTimeString =
          '${(elapsedTime ~/ 60).toString().padLeft(2, '0')}:${(elapsedTime % 60).toString().padLeft(2, '0')}';
    } else {
      elapsedTime = 0;
      elapsedTimeString = '00:00';
    }
  }

  Future<bool> start() async {
    isRunning = true;
    updateElapsedTime(true);
    notifyListeners();
    print('timer started');
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (!isRunning) {
        timer.cancel();
        print('timer stopped');
      } else {
        updateElapsedTime(false);
        notifyListeners();
        print('timer tick $elapsedTime');
      }
    });
    Position currentPosition = await geolocator.getCurrentPosition();
    print('Current position is: $currentPosition');
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    positionStream = await geolocator.getPositionStream();
    print('positionStream subscription started');
    return true;
  }

  Future<void> stop() async {
    isRunning = false;
    notifyListeners();
  }

// createDummyData is just used for testing
  void createDummyData() {}
}

class _lapTimes {
  int lapNumber;
  int lapTime;
}

// LocationEngine takes no parameters
// getCurrentLocation method returns a Future with a Position object
class LocationEngine {
  Position currentPosition;

  Future<Position> getCurrentLocation() async {
    Geolocator().forceAndroidLocationManager = true;
    try {
      currentPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}
