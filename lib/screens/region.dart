import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../widgets/drawer.dart';
import '../models/covid19data.dart';

class RegionPage extends StatefulWidget {
  static const String route = '/region';
  @override
  _RegionState createState() => _RegionState();
}

class VerticalText extends StatelessWidget {
  const VerticalText(this.data);
  final String data;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(data, textAlign: TextAlign.center),
    );
  }
}

class _RegionState extends State<RegionPage> {
  String region;
  var records = <Record>[];
  var seriesList = <LineSeries<Record, DateTime>>[];
  _RecordsDataSource _rows;
  var logScale = false;

  prepareData(context){
    var _region = ModalRoute.of(context).settings.arguments;
    if(_region == region){ return; }
    region = _region;
    var data = Provider.of<COVID19DataModel>(context);
    records = data.getRegionRecords(region);
    setState(() {
      seriesList = [
        LineSeries<Record, DateTime>(
            name: 'Positivi',
            dataSource: records,
            xValueMapper: (Record record, _) => record.data,
            yValueMapper: (Record record, _) => record.totalePositivi,
            color: Colors.lightBlue,
        ),
        LineSeries<Record, DateTime>(
            name: 'Guariti',
            dataSource: records,
            xValueMapper: (Record record, _) => record.data,
            yValueMapper: (Record record, _) => record.dimessiGuariti,
            color: Colors.lightGreen,
        ),
        LineSeries<Record, DateTime>(
            name: 'Deceduti',
            dataSource: records,
            xValueMapper: (Record record, _) => record.data,
            yValueMapper: (Record record, _) => record.deceduti,
            color: Colors.black,
        ),
      ];
      _rows = _RecordsDataSource(records);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    prepareData(context);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
                child: SfCartesianChart(
                  legend: Legend(isVisible: true, position: LegendPosition.top),
                  primaryXAxis: DateTimeAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  primaryYAxis: (
                      logScale ?
                        LogarithmicAxis(interactiveTooltip: InteractiveTooltip(enable: false))
                      :
                        NumericAxis(interactiveTooltip: InteractiveTooltip(enable: false))
                  ),
                  series: seriesList,
                  tooltipBehavior: TooltipBehavior(enable: true),
                  zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true, zoomMode: ZoomMode.xy, enablePanning: true
                  ),
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 24.0),
              child: SwitchListTile(
                title: const Text("Use logarithmic scale"),
                value: logScale,
                onChanged: (value) { setState(() => logScale = value); },
              ),
            ),
            new Scrollbar(
              child: new PaginatedDataTable(
                rowsPerPage: 20,
                header: Text("Data"),
                columnSpacing: 12.0,
                dataRowHeight: 20.0,
                headingRowHeight: 120.0,
                columns: [
                  DataColumn(label: const VerticalText('Data'), numeric: true),
                  DataColumn(label: const VerticalText('Ricoverati\ncon sintomi'), numeric: true),
                  DataColumn(label: const VerticalText('Terapia\nintensiva'), numeric: true),
                  DataColumn(label: const VerticalText("Totale\nopspedalizzati"), numeric: true),
                  DataColumn(label: const VerticalText('In isolamento\ndomiciliare'), numeric: true),
                  DataColumn(label: const VerticalText('Totale\npositivi'), numeric: true),
                  DataColumn(label: const VerticalText('Nuovi\npositivi'), numeric: true),
                  DataColumn(label: const VerticalText('Variazione totale\npositivi'), numeric: true),
                  DataColumn(label: const VerticalText('Dimessi\no guariti'), numeric: true),
                  DataColumn(label: const VerticalText('Deceduti'), numeric: true),
                  DataColumn(label: const VerticalText('Totale casi'), numeric: true),
                  DataColumn(label: const VerticalText('Tamponi'), numeric: true),
                  DataColumn(label: const VerticalText('Casi Testati'), numeric: true),
                  DataColumn(label: const VerticalText('Note')),
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
          DataCell(Text('${record.totalePositivi}')),
          DataCell(Text('${record.nuoviPositivi}')),
          DataCell(Text('${record.variazioneTotalePositivi}')),
          DataCell(Text('${record.dimessiGuariti}')),
          DataCell(Text('${record.deceduti}')),
          DataCell(Text('${record.totaleCasi}')),
          DataCell(Text('${record.tamponi}')),
          DataCell(Text('${record.casiTestati}')),
          DataCell(Text('${record.noteIt}')),
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