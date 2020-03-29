import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

class CreditsPage extends StatelessWidget {
  static const String route = '/credits';
  static const String title = "Credits";

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<COVID19DataModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: buildDrawer(context, route),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () async {
            var result = await data.fetchData(ignorecache: true);
            final snackBar = SnackBar(
              content: Text('Refreshed data: ${result}'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
        );
      }),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text("Presidenza del Consiglio dei Ministri\nDipartimento della Protezione Civile"),
            ),
          ],
        ),
      ),
    );

  }
}
