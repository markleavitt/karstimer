import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'race_data.dart';
import 'constants.dart';

class LapTile extends StatelessWidget {
  final int index;
  LapTile(this.index);
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
