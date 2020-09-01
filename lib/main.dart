//  Karstimer (c) 2020 Wearable Health Labs LLC

import 'package:flutter/material.dart';
import 'package:karstimer/race_data.dart';
import 'tab_track.dart';
import 'tab_lap_timer.dart';
import 'tab_settings.dart';
import 'race_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await myRaceData.checkStatus();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => myRaceData,
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
}
