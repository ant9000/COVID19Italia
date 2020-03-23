import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
//import 'package:data_tables/data_tables.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

class RegionPage extends StatefulWidget {
  static const String route = '/region';

  @override
  _RegionState createState() => _RegionState();
}

class _RegionState extends State<RegionPage> {
  String region;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var data = Provider.of<COVID19DataModel>(context);
    region = ModalRoute.of(context).settings.arguments;
    var records = data.getRegion(region);
    var colors = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.red.shadeDefault,
    ];
    List<charts.Series<Record, DateTime>> seriesList = [
      new charts.Series<Record, DateTime>(
        id: 'Attualmente positivi',
        colorFn: (_, __) => colors[0],
        domainFn: (Record record, _) => record.data,
        measureFn: (Record record, _) => record.totaleAttualmentePositivi,
        data: records,
      ),
      new charts.Series<Record, DateTime>(
        id: 'Guariti',
        colorFn: (_, __) => colors[1],
        domainFn: (Record record, _) => record.data,
        measureFn: (Record record, _) => record.dimessiGuariti,
        data: records,
      ),
      new charts.Series<Record, DateTime>(
        id: 'Morti',
        colorFn: (_, __) => colors[2],
        domainFn: (Record record, _) => record.data,
        measureFn: (Record record, _) => record.deceduti,
        data: records,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('$region')),
      drawer: buildDrawer(context, RegionPage.route),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new Column(
                    children: <Widget>[
                      new SizedBox(
                        height: 0.5*size.height,
                        child: new charts.TimeSeriesChart(
                          seriesList,
                          behaviors: [new charts.SeriesLegend(
                            horizontalFirst: false,
                            cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                            showMeasures: true,
                            measureFormatter: (num value) {
                              return value == null ? '-' : '${value.toInt()}';
                            },
                          )],
                        ),
                      ),

                     /* new NativeDataTable.builder(
                        itemCount: records.length,
                        rowsPerPage: records.length,
                        firstRowIndex: 0,
                        itemBuilder: (int index) {
                          final Record record = records[index];
                          return DataRow.byIndex(
                              index: index,
                              cells: <DataCell>[
                                DataCell(Text('${record.data}')),
                                DataCell(Text('${record.ricoveratiConSintomi}')),
                                DataCell(Text('${record.terapiaIntensiva}')),
                                DataCell(Text('${record.isolamentoDomiciliare}')),
                                DataCell(Text('${record.totaleAttualmentePositivi}')),
                                DataCell(Text('${record.dimessiGuariti}')),
                                DataCell(Text('${record.deceduti}%')),
                                DataCell(Text('${record.totaleCasi}%')),
                              ]);
                        },
                        columns: [
                          DataColumn(label: const Text('Data')),
                          DataColumn(label: const Text('Ricoverati'), numeric: true),
                          DataColumn(label: const Text('Terapia intensiva'), numeric: true),
                          DataColumn(label: const Text('In isolamento a casa'), numeric: true),
                          DataColumn(label: const Text('Totale attualmente positivi'), numeric: true),
                          DataColumn(label: const Text('Guariti'), numeric: true),
                          DataColumn(label: const Text('Morti'), numeric: true),
                          DataColumn(label: const Text('Totale casi'), numeric: true),
                        ],
                      ),*/
                    ]
                )
            ),
          ],
        ),
      ),
    );
  }
}
