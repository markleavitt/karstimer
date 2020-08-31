//  Karstimer (c) 2020 Wearable Health Labs LLC
//  Geolocation library Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';
import 'tab_track.dart';
import 'tab_lap_timer.dart';
import 'tab_settings.dart';

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
              title: Text('Lap Timer'),
              icon: Icon(Icons.timer),
            ),
            BottomNavigationBarItem(
              title: Text('Track'),
              icon: Icon(Icons.location_on),
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
                  return TabLapTimer();
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
        print('Location services enabled');
      }
      // Location Services Enabled
    });
  }
}
