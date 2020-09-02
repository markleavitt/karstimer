import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'race_data.dart';
import 'lap_tile.dart';

class TabLapTimer extends StatefulWidget {
  @override
  _TabLapTimerState createState() => _TabLapTimerState();
}

class _TabLapTimerState extends State<TabLapTimer> {
  //ScrollController _myListScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(),
        Expanded(
          child: ListView.builder(
            //controller: _myListScrollController,
            itemCount: Provider.of<RaceData>(context).lapStats.length,
            reverse: false,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return LapTile(index);
            },
          ),
        ),
        Provider.of<RaceData>(context).isAutoLapMark
            ? Container()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
                child: RaisedButton(
                  onPressed: () {
                    if (Provider.of<RaceData>(context, listen: false)
                        .isRunning) {
                      Provider.of<RaceData>(context, listen: false).markLap();
                    }
                  },
                  color: Colors.deepOrange,
                  child: Text(
                    'Mark Lap',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'RacingSansOne',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

// Builds the Header with a button and elapsed time display
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 3,
            child: _HeaderButton(
              title:
                  Provider.of<RaceData>(context).isRunning ? 'STOP' : 'START',
              color: Provider.of<RaceData>(context).isRunning
                  ? Colors.red
                  : Colors.green[700],
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              Provider.of<RaceData>(context).elapsedTimeString,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 80.0,
                fontFamily: 'RacingSansOne',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Builds a button with specified title and color; connects via Provider
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
              Radius.circular(8.0),
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
