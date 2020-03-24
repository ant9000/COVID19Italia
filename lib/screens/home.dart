import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

class HomePage extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<COVID19DataModel>(context);
    var records = data.lastDayRecords();
    var markers = <CircleMarker>[];
    var max = 0;
    for(var record in records) {
      if(record.totaleAttualmentePositivi > max){ max = record.totaleAttualmentePositivi; }
    }
    for(var record in records){
      var casi = record.totaleAttualmentePositivi;
      var r = 40 * ((max > 0)? log(1 + casi.toDouble()/max.toDouble()) : 0);
      print("${record.denominazioneRegione} $casi $max $r");
      markers.add(CircleMarker(
        radius: r,
        point: LatLng(record.lat, record.long),
        color: Colors.red,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: buildDrawer(context, route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('Italy.'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(42.088, 12.564),
                  zoom: 5.0,
/*
                  swPanBoundary: LatLng(56.6877, 11.5089),
                  nePanBoundary: LatLng(56.7378, 11.6644),
*/
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
