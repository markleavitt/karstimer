import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocation/geolocation.dart';

class TabSettings extends StatefulWidget {
  @override
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  GeolocationResult _locationOperationalResult;
  GeolocationResult _requestPermissionResult;

  _checkLocationOperational() async {
    final GeolocationResult result = await Geolocation.isLocationOperational();

    if (mounted) {
      setState(() {
        _locationOperationalResult = result;
      });
    }
  }

  _requestPermission() async {
    final GeolocationResult result =
        await Geolocation.requestLocationPermission(
      permission: const LocationPermission(
        android: LocationPermissionAndroid.fine,
        ios: LocationPermissionIOS.always,
      ),
      openSettingsIfDenied: true,
    );

    if (mounted) {
      setState(() {
        _requestPermissionResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(context: context, tiles: [
          _Item(
            title: 'Geolocator permission',
            successLabel: 'Granted',
            result: _requestPermissionResult,
            onPressed: _requestPermission,
          ),
          _Item(
            title: 'Geolocator operational',
            successLabel: 'Yes',
            result: _locationOperationalResult,
            onPressed: _checkLocationOperational,
          ),
        ]).toList(),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  _Item({
    @required this.title,
    @required this.successLabel,
    @required this.result,
    @required this.onPressed,
  });

  final String title;
  final String successLabel;
  final GeolocationResult result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    String value;
    String status;
    Color color;

    if (result != null) {
      if (result.isSuccessful) {
        value = successLabel;
        status = 'success';
        color = Colors.green;
      } else {
        switch (result.error.type) {
          case GeolocationResultErrorType.runtime:
            value = 'Failure: ${result.error.message}';
            break;
          case GeolocationResultErrorType.locationNotFound:
            value = 'Location not found';
            break;
          case GeolocationResultErrorType.serviceDisabled:
            value = 'Service disabled';
            break;
          case GeolocationResultErrorType.permissionNotGranted:
            value = 'Permission not granted';
            break;
          case GeolocationResultErrorType.permissionDenied:
            value = 'Permission denied';
            break;
          case GeolocationResultErrorType.playServicesUnavailable:
            value = 'Play services unavailable: ${result.error.additionalInfo}';
            break;
        }

        status = 'failure';
        color = Colors.red;
      }
    } else {
      value = 'Unknown';
      status = 'undefined';
      color = Colors.blueGrey;
    }

    final text = '$title: $value';

    final List<Widget> content = <Widget>[
      Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(
        height: 3,
      ),
      Text(
        'Tap to trigger',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ];

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: Colors.white,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
