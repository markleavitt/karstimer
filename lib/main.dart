//  Karstimer (c) 2020 Wearable Health Labs LLC

import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';
import 'package:karstimer/time_locn.dart';
import 'tab_track.dart';
import 'tab_lap_timer.dart';
import 'tab_settings.dart';
import 'time_locn.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Geolocation.loggingEnabled = true;
    enableLocationServices();
    return ChangeNotifierProvider(
      create: (_) => TimeAndLocation(),
      child: MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.timer, size: 40.0)),
                    Tab(icon: Icon(Icons.location_on, size: 40.0)),
                    Tab(icon: Icon(Icons.settings, size: 40.0))
                  ],
                  unselectedLabelColor: Colors.black,
                ),
                title: Center(
                  child: Text(
                    'KarsTimer',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontFamily: 'RacingSansOne',
                    ),
                  ),
                ),
              ),
              body: TabBarView(children: [
                TabLapTimer(),
                TabTrack(),
                TabSettings(),
              ])),
        ),
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
