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
  String date;
  var markers = <CircleMarker>[];

  computeStep(List<Record> records){
    final formatter = new DateFormat('dd/MM/yyyy');
    double tot = 0;
    for(var record in records) {
      if(record.denominazioneRegione == "ITALIA"){
        tot = record.totaleAttualmentePositivi.toDouble();
        break;
      }
    }
    setState(() {
      date = records.isNotEmpty ? formatter.format(records[0].data) : '';
      print("[$date]");
      markers.clear();
      for(var record in records) {
        if (record.denominazioneRegione != "ITALIA") {
          var casi = record.totaleAttualmentePositivi.toDouble();
          var r = tot > 0 ? 100 * log(1 + casi / tot) : 0.0;
          print("${record.denominazioneRegione} $r");
          markers.add(CircleMarker(
            radius: r,
            point: LatLng(record.lat, record.long),
            color: Colors.red,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<COVID19DataModel>(context);
    var records = data.lastDayRecords();
    computeStep(records);

    return Scaffold(
      appBar: AppBar(title: Text('CODIV-19 Italia ')),
      drawer: buildDrawer(context, HomePage.route),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () {
// TODO: animare il raggio dei markers
//          for(var day in data.getDays()){
//            computeStep(data.getDayRecords(day));
//            sleep(Duration(milliseconds: 500));
//          }
        },
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
