import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../screens/home.dart';
import '../screens/region.dart';
import '../screens/credits.dart';
import '../models/covid19data.dart';

Drawer buildDrawer(BuildContext context, String currentRoute) {
  var data = Provider.of<COVID19DataModel>(context);
  String region = ModalRoute.of(context).settings.arguments;
  var regions = data.getRegions();
  final formatter = new DateFormat('dd/MM/yyyy');
  var day = data.lastDay();
  var date = day != null ? formatter.format(day) : '';
  var tiles = <ListTile>[];

  for(var r in regions){
    tiles.add(ListTile(
      title: Text(r.denominazioneRegione),
      selected: currentRoute == RegionPage.route && region == r.denominazioneRegione,
      onTap: () => Navigator.pushNamed(context, RegionPage.route, arguments: r.denominazioneRegione),
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
          title: const Text(HomePage.title),
          selected: currentRoute == HomePage.route,
          onTap: () => Navigator.pushReplacementNamed(context, HomePage.route),
        ),
        Divider(),
        ... tiles,
        Divider(),
        ListTile(
          title: const Text(CreditsPage.title),
          selected: currentRoute == CreditsPage.route,
          onTap: () => Navigator.pushReplacementNamed(context, CreditsPage.route),
        )
      ],
    ),
  );
}
