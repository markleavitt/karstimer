//  Karstimer (c) 2020 Wearable Health Labs LLC

import 'package:flutter/material.dart';
import 'package:karstimer/race_data.dart';
import 'tab_track.dart';
import 'tab_best_time.dart';
import 'tab_lap_timer.dart';
import 'tab_settings.dart';
import 'race_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await myRaceData.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => myRaceData,
      child: MaterialApp(
        theme: myRaceData.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.timer, size: 40.0)),
                  Tab(icon: Icon(Icons.list, size: 40.0)),
                  Tab(icon: Icon(Icons.location_on, size: 40.0)),
                  Tab(icon: Icon(Icons.settings, size: 40.0))
                ],
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
            body: TabBarView(
              children: [
                TabBestTime(),
                TabLapTimer(),
                TabTrack(),
                TabSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
