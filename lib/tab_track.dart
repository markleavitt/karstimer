import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';

class TabTrack extends StatefulWidget {
  @override
  _TabTrackState createState() => _TabTrackState();
}

class _TabTrackState extends State<TabTrack> {
  List<LocationData> _locations = [];
  List<StreamSubscription<dynamic>> _subscriptions = [];
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Future tab for map tracking'));
  }
}

class LocationData {
  LocationData({
    @required this.id,
    this.result,
    @required this.origin,
    @required this.color,
    @required this.createdAtTimestamp,
    this.elapsedTimeSeconds,
  });

  final int id;
  final LocationResult result;
  final String origin;
  final Color color;
  final int createdAtTimestamp;
  final int elapsedTimeSeconds;
}
