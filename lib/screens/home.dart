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

class _HomePageState extends State<HomePage> {
  DateTime day;
  double max;
  var animating = false;

  didChangeDependencies() {
    super.didChangeDependencies();
    var data = Provider.of<COVID19DataModel>(context);
    day = data.lastDay();
    var records = data.getDayRecords(day);
    for(var record in records) {
      if(record.denominazioneRegione == "ITALIA"){
        max = record.totaleAttualmentePositivi.toDouble();
        break;
      }
    }
  }

  animate(COVID19DataModel data){
    var days = data.getDays();
    if(animating) { // stop
      setState(() {
        day = days.last;
        animating = false;
      });
    } else { // start
      setState(() => animating = true);
      for (var item in days.asMap().entries) {
        new Future.delayed(Duration(milliseconds: 150 * item.key), () {
          if (!animating) {
            return;
          }
          setState(() {
            day = item.value;
            if (day == days.last) {
              animating = false;
            }
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<COVID19DataModel>(context);
    var markers = <CircleMarker>[];
    var date = "";
    if(day != null) {
      final formatter = new DateFormat('dd/MM/yyyy');
      date = formatter.format(day);
      for (var record in data.getDayRecords(day)) {
        if (record.denominazioneRegione != "ITALIA") {
          var casi = record.totaleAttualmentePositivi.toDouble();
          var r = max > 0 ? 100 * log(1 + casi / max) : 0.0;
          markers.add(CircleMarker(
            radius: r,
            point: LatLng(record.lat, record.long),
            color: Colors.red,
          ));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('CODIV-19 Italia ')),
      drawer: buildDrawer(context, HomePage.route),
      floatingActionButton: FloatingActionButton(
        child: Icon(animating ? Icons.stop : Icons.play_arrow),
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
