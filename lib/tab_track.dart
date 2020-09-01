import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'race_data.dart';
import 'package:provider/provider.dart';
import 'lap_tile.dart';
import 'constants.dart';

class TabTrack extends StatefulWidget {
  @override
  _TabTrackState createState() => _TabTrackState();
}

class _TabTrackState extends State<TabTrack> {
  int indexToView = 0; // Defaults to most recent lap, stored at index 0
  GoogleMapController mapController;
  final LatLng _center = LatLng(myRaceData.mapCenterPosition.latitude,
      myRaceData.mapCenterPosition.longitude);
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Lap: ${Provider.of<RaceData>(context).lapStats[indexToView].lapNumber}',
                style: kLapStyle,
              ),
              RaisedButton(
                child: Text('Later'),
                onPressed: () {
                  indexToView--;
                },
              ),
              RaisedButton(
                child: Text('Earlier'),
                onPressed: () {
                  indexToView++;
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 16.0,
            ),
            markers: Provider.of<RaceData>(context).markers.values.toSet(),
          ),
        ),
      ],
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
