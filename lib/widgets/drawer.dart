import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../screens/home.dart';
import '../screens/region.dart';
import '../models/covid19data.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  var data = Provider.of<COVID19DataModel>(context);
  String region = ModalRoute.of(context).settings.arguments;
  var records = data.lastDayRecords();
  final formatter = new DateFormat('dd/MM/yyyy');
  var date = records.isNotEmpty ? formatter.format(records[0].data) : '';
  var tiles = <ListTile>[];
  for(var record in records){
    tiles.add(ListTile(
      title: Text(record.denominazioneRegione),
      selected: currentRoute == RegionPage.route && region == record.denominazioneRegione,
      onTap: () => Navigator.pushNamed(context, RegionPage.route, arguments: record.denominazioneRegione),
    ));
  }

  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Center(
            child: Text('CODIV-19 Italia [$date]'),
          ),
        ),
        ListTile(
          title: const Text('Home'),
          selected: currentRoute == HomePage.route,
          onTap: () => Navigator.pushReplacementNamed(context, HomePage.route),
        ),
        ... tiles,
      ],
    ),
  );
}
