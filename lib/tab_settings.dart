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
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Clear data", style: kSettingStyle),
              RaisedButton(
                child: Text('CLEAR'),
                onPressed: () {
                  myRaceData.clearData();
                },
              )
            ],
          ),
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Automatic lap marking (GPS)", style: kSettingStyle),
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
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text('Colorize map track with accel/decel data',
                      style: kSettingStyle)),
              Expanded(
                child: Slider(
                  value: myRaceData.colorSensAccel,
                  min: 0.0,
                  max: 10.0,
                  divisions: 5,
                  onChanged: (double newValue) {
                    setState(() {
                      myRaceData.setColorSensAccel(newValue);
                    });
                  },
                ),
              )
            ],
          ),
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("GPS update trigger:  DISTANCE", style: kSettingStyle),
              Switch(
                value: myRaceData.isTimedUpdates,
                onChanged: (bool newValue) {
                  setState(() {
                    myRaceData.setIsTimedUpdates(newValue);
                  });
                },
              ),
              Text("TIME", style: kSettingStyle),
            ],
          ),
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Simulate GPS data", style: kSettingStyle),
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
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Dark theme (requires app restart)", style: kSettingStyle),
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
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "App version:",
              ),
              Text(
                myRaceData.appVersion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 3,
      thickness: 2,
    );
  }
}
