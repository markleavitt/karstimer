import 'package:flutter/material.dart';
import 'package:karstimer/constants.dart';
import 'package:karstimer/race_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class TabSettings extends StatefulWidget {
  @override
  _TabSettingsState createState() => _TabSettingsState();
}

class _TabSettingsState extends State<TabSettings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
      child: Column(
        children: [
          Divider(
            thickness: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Clear data", style: kLapButtonStyle),
              RaisedButton(
                child: Text('CLEAR'),
                onPressed: () {
                  myRaceData.clearData();
                },
              )
            ],
          ),
          Divider(
            thickness: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Automatic lap marking (GPS)", style: kLapButtonStyle),
              Switch(
                value: myRaceData.isAutoLapMark,
                onChanged: (bool newValue) {
                  setState(() {
                    myRaceData.setIsAutoLapMark(newValue);
                  });
                },
              ),
            ],
          ),
          Divider(
            thickness: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Simulate GPS data", style: kLapButtonStyle),
              Switch(
                value: myRaceData.isSimulatedData,
                onChanged: (bool newValue) {
                  setState(() {
                    myRaceData.setIsSimulatedData(newValue);
                  });
                },
              ),
            ],
          ),
          Divider(
            thickness: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("GPS update trigger:  DISTANCE", style: kLapButtonStyle),
              Switch(
                value: myRaceData.isTimedUpdates,
                onChanged: (bool newValue) {
                  setState(() {
                    myRaceData.setIsTimedUpdates(newValue);
                  });
                },
              ),
              Text("TIME", style: kLapButtonStyle),
            ],
          ),
          Divider(
            thickness: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Dark theme (requires app restart)", style: kLapButtonStyle),
              Switch(
                value: myRaceData.isDarkTheme,
                onChanged: (bool newValue) {
                  setState(() {
                    myRaceData.setIsDarkTheme(newValue);
                  });
                },
              ),
            ],
          ),
          Divider(
            thickness: 4,
          ),
        ],
      ),
    );
  }
}
