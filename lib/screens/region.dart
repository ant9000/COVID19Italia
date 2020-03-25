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
  _RecordsDataSource _rows;
  final colors = {
    'positivi': charts.MaterialPalette.blue.shadeDefault,
    'guariti':  charts.MaterialPalette.green.shadeDefault,
    'deceduti': charts.MaterialPalette.red.shadeDefault,
  };

  prepareData(context){
    var _region = ModalRoute.of(context).settings.arguments;
    if(_region == region){ return; }
    region = _region;
    var data = Provider.of<COVID19DataModel>(context);
    records = data.getRegion(region);
    setState(() {
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
      _rows = _RecordsDataSource(records);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rows == null) {
      prepareData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    prepareData(context);

    return Scaffold(
      appBar: AppBar(title: Text('$region')),
      drawer: buildDrawer(context, RegionPage.route),
      body: ListView(
        padding: EdgeInsets.all(8.0),
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: new SizedBox(
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
            ),
            new Scrollbar(
              child: new PaginatedDataTable(
                rowsPerPage: 10,
                header: Text("Data"),
                columnSpacing: 10.0,
                dataRowHeight: 20.0,
                columns: [
                  DataColumn(label: const Text('Data')),
                  DataColumn(label: const Text('Ricoverati'), numeric: true),
                  DataColumn(label: const Text('TI'), numeric: true),
                  DataColumn(label: const Text("Ospedale"), numeric: true),
                  DataColumn(label: const Text('Isolamento'), numeric: true),
                  DataColumn(label: const Text('Positivi'), numeric: true),
                  DataColumn(label: const Text('Nuovi positivi'), numeric: true),
                  DataColumn(label: const Text('Guariti'), numeric: true),
                  DataColumn(label: const Text('Morti'), numeric: true),
                  DataColumn(label: const Text('Totale casi'), numeric: true),
                  DataColumn(label: const Text('Tamponi'), numeric: true),
                ],
                source: _rows,
              ),
            ),
          ],
      ),
    );
  }
}

class _RecordsDataSource extends DataTableSource {
  List<Record> records;
  _RecordsDataSource(this.records);

  @override
  DataRow getRow(int index) {
    final formatter = new DateFormat('dd/MM');
    assert(index >= 0);
    if (index >= records.length) return null;
    final record = records[records.length - index -1];
    return DataRow.byIndex(
      index: index,
      cells: [
          DataCell(Text('${formatter.format(record.data)}')),
          DataCell(Text('${record.ricoveratiConSintomi}')),
          DataCell(Text('${record.terapiaIntensiva}')),
          DataCell(Text('${record.totaleOspedalizzati}')),
          DataCell(Text('${record.isolamentoDomiciliare}')),
          DataCell(Text('${record.totaleAttualmentePositivi}')),
          DataCell(Text('${record.nuoviAttualmentePositivi}')),
          DataCell(Text('${record.dimessiGuariti}')),
          DataCell(Text('${record.deceduti}')),
          DataCell(Text('${record.totaleCasi}')),
          DataCell(Text('${record.tamponi}')),
      ],
    );
  }

  @override
  int get rowCount => records.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}