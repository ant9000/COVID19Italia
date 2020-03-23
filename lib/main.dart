import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/home.dart';
// import './screens/data.dart';
import './models/covid19data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => COVID19DataModel()),
      ],
      child: MaterialApp(
        title: 'COVID-19 Italia',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: HomePage.route,
        routes: <String, WidgetBuilder>{
          HomePage.route: (context) => HomePage(),
//        DataPage.route: (context) => DataPage(),
        },
      ),
    );
  }
}
