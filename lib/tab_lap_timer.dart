import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'race_data.dart';

class TabLapTimer extends StatefulWidget {
  @override
  _TabLapTimerState createState() => _TabLapTimerState();
}

class _TabLapTimerState extends State<TabLapTimer> {
  bool _isTiming = false;
  _onTogglePressed() async {
    if (_isTiming) {
      await myRaceData.stop();
      _isTiming = false;
    } else {
      await myRaceData.start();
      _isTiming = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(),
        Expanded(
          child: ListView.builder(
            itemCount: Provider.of<RaceData>(context).lapTimes.length + 1,
            itemBuilder: (context, index) {
              return Text('$index');
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: _HeaderButton(
              title:
                  Provider.of<RaceData>(context).isRunning ? 'STOP' : 'START',
              color: Provider.of<RaceData>(context).isRunning
                  ? Colors.red
                  : Colors.green[700],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              Provider.of<RaceData>(context).elapsedTimeString,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  _HeaderButton({@required this.title, @required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () {
          Provider.of<RaceData>(context, listen: false).toggleState();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(
              Radius.circular(6.0),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40.0,
              fontFamily: 'RacingSansOne',
            ),
          ),
        ),
      ),
    );
  }
}
