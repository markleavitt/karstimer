import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'race_data.dart';

class TabTimer extends StatefulWidget {
  @override
  _TabTimerState createState() => _TabTimerState();
}

class _TabTimerState extends State<TabTimer> {
  //ScrollController _myListScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(),
        BigTimer(
          caption:
              'Last Lap (#${Provider.of<RaceData>(context).currentLapNumber - 1})',
          timeDisplay: '${Provider.of<RaceData>(context).lastLapTimeString}',
          backColor: Colors.grey[200],
        ),
        BigTimer(
          caption:
              'Best Lap (#${Provider.of<RaceData>(context).bestLapNumber ?? ""})',
          timeDisplay: '${Provider.of<RaceData>(context).bestLapTimeString}',
          backColor: Colors.yellow[700],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: RaisedButton(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onPressed: () {
              if (Provider.of<RaceData>(context, listen: false).isRunning) {
                Provider.of<RaceData>(context, listen: false).markLap();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                Provider.of<RaceData>(context).isAutoLapMark
                    ? 'MARK LAP\n(Override GPS)'
                    : 'MARK LAP\n(Manual Mode)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  //color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BigTimer extends StatelessWidget {
  BigTimer({this.caption, this.timeDisplay, this.backColor});
  final String caption;
  final String timeDisplay;
  final Color backColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ),
      child: Stack(
        children: [
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: backColor,
                border: Border.all(
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  timeDisplay,
                  style: kTimerStyle,
                ),
              ),
            ),
          ),
          Positioned(
            child: Text(
              caption,
              style: kTimerCaptionStyle,
            ),
            left: 20,
            top: 4,
          ),
        ],
      ),
    );
  }
}

// Builds the Header with the StartStop button and a small current elapsed time display
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 7,
            child: _StartStopButton(
              title:
                  Provider.of<RaceData>(context).isRunning ? 'STOP' : 'START',
              color: Provider.of<RaceData>(context).isRunning
                  ? Colors.red
                  : Colors.green[700],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  'Lap ${Provider.of<RaceData>(context).currentLapNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${Provider.of<RaceData>(context).currentSpeedMph.toStringAsFixed(0)} mph',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Provider.of<RaceData>(context).elapsedTimeString,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartStopButton extends StatelessWidget {
  _StartStopButton({@required this.title, @required this.color});
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: RaisedButton(
        color: color,
        elevation: 16.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        onPressed: () {
          Provider.of<RaceData>(context, listen: false).toggleState();
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60.0,
              fontFamily: 'RacingSansOne',
            ),
          ),
        ),
      ),
    );
  }
}
