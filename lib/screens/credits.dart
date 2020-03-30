import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

openLink (context, link) async {
  if (await canLaunch(link)) {
    await launch(link, forceSafariVC: true);
  } else {
    final snackBar = SnackBar(
      content: Text('Impossibile aprire: $link'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

class CreditsPage extends StatelessWidget {
  static const String route = '/credits';
  static const String title = "Credits";
  static const url = 'https://github.com/pcm-dpc/COVID-19';
  static const urlCode = 'https://github.com/ant9000/COVID19Italia';
  static const urlGPLv3 = 'https://www.gnu.org/licenses/gpl-3.0.txt';

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
              content: Text('Dati aggiornati: $result'),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
        );
      }),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Text.rich(
                TextSpan(
                  style:
                  TextStyle(fontSize: 16.0),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Dati a cura di:\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "Presidenza del Consiglio dei Ministri\n" +
                            "Dipartimento della Protezione Civile\n"
                    ),
                    TextSpan(
                      text: url,
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () => openLink(context, url),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Applicazione sviluppata da:\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "Antonio Galea\n"),
                    TextSpan(
                      text: urlCode,
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () => openLink(context, urlCode),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Licenza:\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "GPLv3\n"),
                    TextSpan(
                      text: urlGPLv3,
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () => openLink(context, urlGPLv3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
