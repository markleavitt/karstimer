import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'race_data.dart';

class TabTrack extends StatefulWidget {
  @override
  _TabTrackState createState() => _TabTrackState();
}

class _TabTrackState extends State<TabTrack> {
  @override
  Widget build(BuildContext context) {
    StreamBuilder<Position>(
      stream: myRaceData.positionStream,
      builder: (context, thisPosition) {
        if (!thisPosition.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Expanded(
          child: ListView(
            children: myRaceData.positionWidgets,
          ),
        );
      },
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
