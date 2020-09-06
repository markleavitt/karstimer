import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'race_data.dart';
import 'constants.dart';

class TabLapTimes extends StatefulWidget {
  @override
  _TabLapTimesState createState() => _TabLapTimesState();
}

class _TabLapTimesState extends State<TabLapTimes> {
  //ScrollController _myListScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: ListView.builder(
        //controller: _myListScrollController,
        itemCount: Provider.of<RaceData>(context).lapStats.length,
        reverse: false,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return _LapTile(index);
        },
      ),
    );
  }
}

class _LapTile extends StatelessWidget {
  final int index;
  _LapTile(this.index);
  @override
  Widget build(BuildContext context) {
    // Prevent display of tile if index is beyond end of range
    if (index > (Provider.of<RaceData>(context).lapStats.length - 1)) {
      return (Container());
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Lap: ${Provider.of<RaceData>(context).lapStats[index].lapNumber.toString().padLeft(3, ' ')}',
            style: kLapStyle,
          ),
          Text(
            'Time: ${Provider.of<RaceData>(context).lapStats[index].lapTimeString}',
            style: kLapStyle,
          ),
        ],
      ),
    );
  }
}
