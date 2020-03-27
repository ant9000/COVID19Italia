import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  DateTime day;
  double max;
  AnimationController animationController;
  Map<String, Animation<double>> radiuses = {};

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(seconds: 3), vsync: this)
    ..addListener( () {
       setState(() {
         //
       });
    }) ;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  didChangeDependencies() {
    super.didChangeDependencies();
    var data = Provider.of<COVID19DataModel>(context);
    day = data.lastDay();
    max = data.getLastPositives()?.toDouble();
    for (var region in data.getRegions()) {
      var items = <TweenSequenceItem<double>>[];
      var r0 = 0.0;
      for (var record in data.getRegionRecords(region.denominazioneRegione)) {
        var r1 = max > 0 ? 100 * log(1 + record.totaleAttualmentePositivi.toDouble() / max) : 0.0;
        items.add(TweenSequenceItem<double>(tween: Tween<double>(begin: r0, end: r1), weight: 1.0));
        r0 = r1;
      }
      radiuses[region.denominazioneRegione] = TweenSequence(items).animate(animationController);
    }
    animationController.value = animationController.upperBound;
  }

  animate(COVID19DataModel data) async {
    if (!animationController.isAnimating) {
      try {
        var days = data.getDays();
        animationController.value = animationController.lowerBound;
        animationController.duration = Duration(milliseconds: 100 * days.length);
        await animationController.forward().orCancel;
      } on TickerCanceled {}
    } else {
      animationController.stop();
      animationController.value = animationController.upperBound;
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<COVID19DataModel>(context);
    var markers = <CircleMarker>[];

    // TODO: animate date
    var date = "";
    if(day != null) {
      final formatter = new DateFormat('dd/MM/yyyy');
      date = formatter.format(day);
    }

    for (var region in data.getRegions()) {
      if (region.denominazioneRegione != "ITALIA") {
        markers.add(CircleMarker(
          radius: radiuses[region.denominazioneRegione].value,
          point: LatLng(region.lat, region.long),
          color: Colors.red,
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('CODIV-19 Italia ')),
      drawer: buildDrawer(context, HomePage.route),
      floatingActionButton: FloatingActionButton(
        child: Icon(animationController.isAnimating ? Icons.stop : Icons.play_arrow),
        onPressed: () => animate(data),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('Positivi al giorno $date'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(41.777545, 12.881348),
                  zoom: 5.0,
                  maxZoom: 7.0,
                  minZoom: 5.0,
                  nePanBoundary: LatLng(47.769334, 18.931354),
                  swPanBoundary: LatLng(35.170229, 6.809863),
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    tileProvider: CachedNetworkTileProvider(),
                  ),
                  CircleLayerOptions(circles: markers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
