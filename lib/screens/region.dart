import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

class RegionPage extends StatefulWidget {
  static const String route = '/region';

  @override
  _RegionState createState() => _RegionState();
}

class _RegionState extends State<RegionPage> {
  String region;
  var records = <Record>[];
  List<charts.Series<Record, DateTime>> seriesList = [];
  var rows = <DataRow>[];
  final colors = {
    'positivi': charts.MaterialPalette.blue.shadeDefault,
    'guariti':  charts.MaterialPalette.green.shadeDefault,
    'deceduti': charts.MaterialPalette.red.shadeDefault,
  };
  final formatter = new DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
  }

  prepareData(context){
    var _region = ModalRoute.of(context).settings.arguments;
    if(_region == region){ return; }
    region = _region;
    var data = Provider.of<COVID19DataModel>(context);
    records = data.getRegion(region);
    seriesList = [
      new charts.Series<Record, DateTime>(
        id: 'Attualmente positivi',
        colorFn: (_, __) => colors['positivi'],
        domainFn: (Record record, _) => record.data,
        measureFn: (Record record, _) => record.totaleAttualmentePositivi,
        data: records,
      ),
      new charts.Series<Record, DateTime>(
        id: 'Guariti',
        colorFn: (_, __) => colors['guariti'],
        domainFn: (Record record, _) => record.data,
        measureFn: (Record record, _) => record.dimessiGuariti,
        data: records,
      ),
      new charts.Series<Record, DateTime>(
        id: 'Morti',
        colorFn: (_, __) => colors['deceduti'],
        domainFn: (Record record, _) => record.data,
        measureFn: (Record record, _) => record.deceduti,
        data: records,
      ),
    ];
    for (var record in records) {
      rows.add(DataRow(
        cells: [
          DataCell(Text('${formatter.format(record.data)}')),
          DataCell(Text('${record.ricoveratiConSintomi}')),
          DataCell(Text('${record.terapiaIntensiva}')),
          DataCell(Text('${record.isolamentoDomiciliare}')),
          DataCell(Text('${record.totaleAttualmentePositivi}')),
          DataCell(Text('${record.dimessiGuariti}')),
          DataCell(Text('${record.deceduti}%')),
          DataCell(Text('${record.totaleCasi}%')),
        ]
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    prepareData(context);

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
                    height: (size.width > size.height ? 0.7 : 0.5) *size.height,
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
                  new DataTable(
                    columns: [
                      DataColumn(label: const Text('Data')),
                      DataColumn(label: const Text('Ricoverati')),
                      DataColumn(label: const Text('TI')),
                      DataColumn(label: const Text('Isolamento')),
                      DataColumn(label: const Text('Positivi')),
                      DataColumn(label: const Text('Guariti')),
                      DataColumn(label: const Text('Morti')),
                      DataColumn(label: const Text('Totale casi')),
                    ],
                    rows: rows,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
