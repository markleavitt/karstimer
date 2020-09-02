import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'race_data.dart';
import 'package:provider/provider.dart';
import 'lap_tile.dart';
import 'constants.dart';

class TabTrack extends StatefulWidget {
  int lapToView;
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

  void increaseLapNumber() {
    if (widget.lapToView <
        Provider.of<RaceData>(context, listen: false).currentLapNumber) {
      setState(() => widget.lapToView++);
    }
  }

  void decreaseLapNumber() {
    if (widget.lapToView > 1) {
      setState(() => widget.lapToView--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lapToView == null) {
      widget.lapToView = 1;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Lap: ${widget.lapToView}',
                style: kLapStyle,
              ),
              RaisedButton(
                child: Text('Later'),
                onPressed: () {
                  increaseLapNumber();
                },
              ),
              RaisedButton(
                child: Text('Earlier'),
                onPressed: () {
                  decreaseLapNumber();
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
            markers: Provider.of<RaceData>(context)
                .lapMarkers[widget.lapToView]
                .values
                .toSet(),
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
