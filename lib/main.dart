//  Karstimer (c) 2020 Wearable Health Labs LLC
//  Geolocation library Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';
import 'tab_location.dart';
import 'tab_track.dart';
import 'tab_settings.dart';

Icon statusIcon = Icon(Icons.location_off);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp() {
    Geolocation.loggingEnabled = true;
  }
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    enableLocationServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              title: Text('Map Track'),
              icon: statusIcon,
            ),
            BottomNavigationBarItem(
              title: Text('Lap Times'),
              icon: Icon(Icons.timer),
            ),
            BottomNavigationBarItem(
              title: Text('Settings'),
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              switch (index) {
                case 0:
                  return TabLocation();
                case 1:
                  return TabTrack();
                case 2:
                  return TabSettings();
              }
            },
          );
        },
      ),
    );
  }

  enableLocationServices() async {
    Geolocation.enableLocationServices().then((result) {
      if (result.isSuccessful == true) {
        setState(() {
          statusIcon = Icon(Icons.location_on);
        });
      }
      // Location Services Enablind Cancelled
    });
  }
}
