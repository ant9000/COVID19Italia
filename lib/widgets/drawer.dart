import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home.dart';
import '../models/covid19data.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  var data = Provider.of<COVID19DataModel>(context);
  var records = data.lastDay();
  var tiles = <ListTile>[];
  for(var record in records){
    tiles.add(ListTile(
      title: Text(record.denominazioneRegione),
      onTap: () => Navigator.pushReplacementNamed(context, HomePage.route),
    ));
  }

  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Center(
            child: Text('COVID-19 Italia'),
          ),
        ),
/*
        ListTile(
          title: const Text('Home'),
          selected: currentRoute == HomePage.route,
          onTap: () => Navigator.pushReplacementNamed(context, HomePage.route),
        ),
 */
        ... tiles,
      ],
    ),
  );
}
