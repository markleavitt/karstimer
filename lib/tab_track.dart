import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'race_data.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

class TabTrack extends StatefulWidget {
  @override
  _TabTrackState createState() => _TabTrackState();
}

class _TabTrackState extends State<TabTrack> {
  int lapToView;
  GoogleMapController mapController;
  final LatLng _center = LatLng(myRaceData.mapCenterPosition.latitude,
      myRaceData.mapCenterPosition.longitude);
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void increaseLapNumber() {
    if (lapToView <
        Provider.of<RaceData>(context, listen: false).currentLapNumber) {
      setState(() => lapToView++);
    }
  }

  void decreaseLapNumber() {
    if (lapToView > 1) {
      setState(() => lapToView--);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure latest lap is showing when view opens
    if (lapToView == null) {
      lapToView = Provider.of<RaceData>(context).currentLapNumber;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Lap: $lapToView',
                style: kLapStyle,
              ),
              RaisedButton(
                child: Text(
                  'Earlier Lap',
                  style: kLapButtonStyle,
                ),
                onPressed: () {
                  decreaseLapNumber();
                },
              ),
              RaisedButton(
                child: Text(
                  'Later Lap',
                  style: kLapButtonStyle,
                ),
                onPressed: () {
                  increaseLapNumber();
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
                .lapMarkers[lapToView]
                .values
                .toSet(),
            polylines: Provider.of<RaceData>(context)
                .polyLines[lapToView]
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
