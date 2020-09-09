import 'package:flutter/material.dart';
import 'package:karstimer/constants.dart';
import 'package:karstimer/race_data.dart';

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
              Text("Save data", style: kSettingStyle),
              RaisedButton(
                child: Text('SAVE'),
                onPressed: () {
                  myRaceData.saveData(context);
                },
              )
            ],
          ),
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Clear starting position", style: kSettingStyle),
              RaisedButton(
                child: Text('CLEAR'),
                onPressed: () {
                  myRaceData.clearStartingPosition();
                },
              )
            ],
          ),
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Erase data", style: kSettingStyle),
              RaisedButton(
                child: Text('ERASE'),
                onPressed: () {
                  myRaceData.eraseData();
                },
              )
            ],
          ),
          MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("LAPS: automatic GPS marking", style: kSettingStyle),
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
          //MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Discard if\nless than ${myRaceData.etToString(myRaceData.minAcceptableLapTime)}',
                  style: kSettingStyle,
                ),
              ),
              Expanded(
                child: Slider(
                  value: myRaceData.minAcceptableLapTime.toDouble(),
                  min: 0.0,
                  max: 600.0,
                  divisions: 20,
                  onChanged: (double newValue) {
                    setState(() {
                      myRaceData.setMinAcceptableLapTime(newValue);
                    });
                  },
                ),
              )
            ],
          ),
          //MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Discard if\nmore than ${myRaceData.etToString(myRaceData.maxAcceptableLapTime)}',
                  style: kSettingStyle,
                ),
              ),
              Expanded(
                child: Slider(
                  value: myRaceData.maxAcceptableLapTime.toDouble(),
                  min: 0.0,
                  max: 600.0,
                  divisions: 20,
                  onChanged: (double newValue) {
                    setState(() {
                      myRaceData.setMaxAcceptableLapTime(newValue);
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
              Text("MAP: show position flags", style: kSettingStyle),
              Switch(
                value: myRaceData.isShowMapFlags,
                onChanged: (bool newValue) {
                  setState(() {
                    myRaceData.setIsShowMapFlags(newValue);
                  });
                },
              ),
            ],
          ),
          //MyDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text('Colorize track with\naccel/decel data',
                      style: kSettingStyle)),
              Expanded(
                child: Slider(
                  value: myRaceData.colorSensAccel,
                  min: 0.0,
                  max: 12.0,
                  divisions: 6,
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
              Text("Simulator (GPS updates + noise)", style: kSettingStyle),
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
