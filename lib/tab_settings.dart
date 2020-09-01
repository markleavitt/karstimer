import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TabSettings extends StatefulWidget {
  @override
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  // GeolocationResult _locationOperationalResult;
  // GeolocationResult _requestPermissionResult;
  //
  // _checkLocationOperational() async {
  //   final GeolocationResult result = await Geolocation.isLocationOperational();
  //
  //   if (mounted) {
  //     setState(() {
  //       _locationOperationalResult = result;
  //     });
  //   }
  // }
  //
  // _requestPermission() async {
  //   final GeolocationResult result =
  //       await Geolocation.requestLocationPermission(
  //     permission: const LocationPermission(
  //       android: LocationPermissionAndroid.fine,
  //       ios: LocationPermissionIOS.always,
  //     ),
  //     openSettingsIfDenied: true,
  //   );
  //
  //   if (mounted) {
  //     setState(() {
  //       _requestPermissionResult = result;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is the settings screen'),
    );
  }
}
