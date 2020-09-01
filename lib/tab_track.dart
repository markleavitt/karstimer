import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'race_data.dart';
import 'package:provider/provider.dart';

class TabTrack extends StatefulWidget {
  @override
  _TabTrackState createState() => _TabTrackState();
}

class _TabTrackState extends State<TabTrack> {
  GoogleMapController mapController;
  final LatLng _center = LatLng(myRaceData.mapCenterPosition.latitude,
      myRaceData.mapCenterPosition.longitude);
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 16.0,
      ),
      markers: {},
    );
  }
}

class LocationData {
  LocationData({
    @required this.id,
    //this.result,
    @required this.origin,
    @required this.color,
    @required this.createdAtTimestamp,
    this.elapsedTimeSeconds,
  });

  final int id;
  //final LocationResult result;
  final String origin;
  final Color color;
  final int createdAtTimestamp;
  final int elapsedTimeSeconds;
}
