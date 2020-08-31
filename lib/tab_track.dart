import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';

class TabTrack extends StatefulWidget {
  @override
  _TabTrackState createState() => _TabTrackState();
}

class _TabTrackState extends State<TabTrack> {
  List<LocationData> _locations = [];
  List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  dispose() {
    super.dispose();
    _subscriptions.forEach((it) => it.cancel());
  }

  _onLastKnownPressed() async {
    final int id = _createLocation('last known', Colors.blueGrey);
    LocationResult result = await Geolocation.lastKnownLocation();
    if (mounted) {
      _updateLocation(id, result);
    }
  }

  _onCurrentPressed() {
    final int id = _createLocation('current', Colors.lightGreen);
    _listenToLocation(
        id, Geolocation.currentLocation(accuracy: LocationAccuracy.best));
  }

  _onSingleUpdatePressed() async {
    final int id = _createLocation('update', Colors.deepOrange);
    _listenToLocation(
        id, Geolocation.singleLocationUpdate(accuracy: LocationAccuracy.best));
  }

  _listenToLocation(int id, Stream<LocationResult> stream) {
    final subscription = stream.listen((result) {
      _updateLocation(id, result);
    });

    subscription.onDone(() {
      _subscriptions.remove(subscription);
    });

    _subscriptions.add(subscription);
  }

  int _createLocation(String origin, Color color) {
    final int lastId = _locations.isNotEmpty
        ? _locations.map((location) => location.id).reduce(math.max)
        : 0;
    final int Id = lastId + 1;

    setState(() {
      _locations.insert(
        0,
        LocationData(
          id: Id,
          result: null,
          origin: origin,
          color: color,
          createdAtTimestamp: DateTime.now().millisecondsSinceEpoch,
          elapsedTimeSeconds: null,
        ),
      );
    });

    return Id;
  }

  _updateLocation(int id, LocationResult result) {
    final int index = _locations.indexWhere((location) => location.id == id);
    assert(index != -1);

    final LocationData location = _locations[index];

    setState(() {
      _locations[index] = LocationData(
        id: location.id,
        result: result,
        origin: location.origin,
        color: location.color,
        createdAtTimestamp: location.createdAtTimestamp,
        elapsedTimeSeconds: (DateTime.now().millisecondsSinceEpoch -
                location.createdAtTimestamp) ~/
            1000,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      _Header(
        onLastKnownPressed: _onLastKnownPressed,
        onCurrentPressed: _onCurrentPressed,
        onSingleUpdatePressed: _onSingleUpdatePressed,
      )
    ];

    children.addAll(ListTile.divideTiles(
      context: context,
      tiles: _locations.map((location) => _Item(data: location)).toList(),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Track'),
      ),
      body: ListView(
        children: children,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  _Header(
      {@required this.onLastKnownPressed,
      @required this.onCurrentPressed,
      @required this.onSingleUpdatePressed});

  final VoidCallback onLastKnownPressed;
  final VoidCallback onCurrentPressed;
  final VoidCallback onSingleUpdatePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _HeaderButton(
                title: 'Last known',
                color: Colors.blueGrey,
                onTap: onLastKnownPressed,
              ),
              _HeaderButton(
                title: 'Current',
                color: Colors.lightGreen,
                onTap: onCurrentPressed,
              ),
              _HeaderButton(
                title: 'Single update',
                color: Colors.deepOrange,
                onTap: onSingleUpdatePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  _HeaderButton(
      {@required this.title, @required this.color, @required this.onTap});

  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: onTap,
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
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  _Item({@required this.data});

  final LocationData data;

  @override
  Widget build(BuildContext context) {
    final List<Widget> content = <Widget>[];

    if (data.result != null) {
      String text;
      if (data.result.isSuccessful) {
        text =
            'Lat: ${data.result.location.latitude} - Lng: ${data.result.location.longitude}';
      } else {
        switch (data.result.error.type) {
          case GeolocationResultErrorType.runtime:
            text = 'Failure: ${data.result.error.message}';
            break;
          case GeolocationResultErrorType.locationNotFound:
            text = 'Location not found';
            break;
          case GeolocationResultErrorType.serviceDisabled:
            text = 'Service disabled';
            break;
          case GeolocationResultErrorType.permissionNotGranted:
            text = 'Permission not granted';
            break;
          case GeolocationResultErrorType.permissionDenied:
            text = 'Permission denied';
            break;
          case GeolocationResultErrorType.playServicesUnavailable:
            text =
                'Play services unavailable: ${data.result.error.additionalInfo}';
            break;
        }
      }

      content.addAll(<Widget>[
        Text(
          text,
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 3.0,
        ),
        Text(
          'Elapsed time: ${data.elapsedTimeSeconds == 0 ? '< 1' : data.elapsedTimeSeconds}s',
          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ]);
    } else {
      content.add(Text(
        'In progress...',
        style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
      ));
    }

    return Container(
      key: Key(data.id.toString()),
      color: Colors.white,
      child: SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  data.origin,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LocationData {
  LocationData({
    @required this.id,
    this.result,
    @required this.origin,
    @required this.color,
    @required this.createdAtTimestamp,
    this.elapsedTimeSeconds,
  });

  final int id;
  final LocationResult result;
  final String origin;
  final Color color;
  final int createdAtTimestamp;
  final int elapsedTimeSeconds;
}
