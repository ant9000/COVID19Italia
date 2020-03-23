import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';

class COVID19DataModel extends ChangeNotifier {
  /* new data published once a day at  6PM */
  final url = 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json';
  List<Record> _records = [];
  var _byDate = LinkedHashMap<DateTime, List<int>>();
  var _byRegion = Map<String, List<int>>();

  COVID19DataModel(){
    fetchData();
  }

  fetchData ({bool ignorecache = false}) async {
    final dir = await getApplicationSupportDirectory();

    var jsonData = "";
    var jsonFile = File('${dir.path}/dpc-covid19-ita-regioni.json');

    if(!ignorecache){
      try {
        if (jsonFile.existsSync()) {
          var now = new DateTime.now();
          var sixthirthyPM = new DateTime(now.year, now.month, now.day, 18, 30);
          var stale = (now.millisecondsSinceEpoch >= sixthirthyPM.millisecondsSinceEpoch) &&
              (jsonFile.lastModifiedSync().millisecondsSinceEpoch < sixthirthyPM.millisecondsSinceEpoch);
          if(!stale) {
            print("FROM CACHE");
            jsonData = jsonFile.readAsStringSync();
          }
        }
      } catch (e) {
        print("IO ERROR: $e");
      }
    }

    if (jsonData == "") {
      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          print("FETCHED FROM GITHUB");
          jsonData = response.body;
          jsonFile.writeAsStringSync(jsonData);
        } else {
          print("HTTP ERROR: ${response.statusCode}");
        }
      }catch (e){
        print("TCP ERROR: $e");
      }
    }

    _records.clear();
    _byDate.clear();
    _byRegion.clear();
    var data = json.decode(jsonData) as List;
    for (var json in data) {
      var record = Record.fromJson(json);
      var idx = _records.length;
      _records.add(record);
      if (!_byDate.containsKey(record.data)) { _byDate[record.data] = []; }
      _byDate[record.data].add(idx);
      if (!_byRegion.containsKey(record.denominazioneRegione)) { _byRegion[record.denominazioneRegione] = []; }
      _byRegion[record.denominazioneRegione].add(idx);
 //     print(json);
    }
    print("_records: ${_records.length}");
    print("_byDate: ${_byDate.keys.length}");
    print("_byRegion: ${_byRegion.keys.length}");
    notifyListeners();
  }

  List<Record> lastDay() {
    if (_byDate.keys.isNotEmpty) {
      var d = _byDate.keys.last;
      print("LAST DAY: $d");
      return List.unmodifiable(_byDate[d].map((idx) => _records[idx]));
    }
    return [];
  }

  List<Record> getRegion(var region){
    print("REGION: $region");
    return List.unmodifiable(_byRegion[region].map((idx) => _records[idx]));
  }
}

@immutable
class Record {
  final  DateTime data;
  final  String   stato;
  final  int      codiceRegione;
  final  String   denominazioneRegione;
  final  double   lat;
  final  double   long;
  final  int      ricoveratiConSintomi;
  final  int      terapiaIntensiva;
  final  int      totaleOspedalizzati;
  final  int      isolamentoDomiciliare;
  final  int      totaleAttualmentePositivi;
  final  int      nuoviAttualmentePositivi;
  final  int      dimessiGuariti;
  final  int      deceduti;
  final  int      totaleCasi;
  final  int      tamponi;

  Record({
    this.data,
    this.stato,
    this.codiceRegione,
    this.denominazioneRegione,
    this.lat,
    this.long,
    this.ricoveratiConSintomi,
    this.terapiaIntensiva,
    this.totaleOspedalizzati,
    this.isolamentoDomiciliare,
    this.totaleAttualmentePositivi,
    this.nuoviAttualmentePositivi,
    this.dimessiGuariti,
    this.deceduti,
    this.totaleCasi,
    this.tamponi,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    data:                      DateTime.parse(json["data"]),
    stato:                     json["stato"],
    codiceRegione:             json["codice_regione"],
    denominazioneRegione:      json["denominazione_regione"],
    lat:                       json["lat"],
    long:                      json["long"],
    ricoveratiConSintomi:      json["ricoverati_con_sintomi"],
    terapiaIntensiva:          json["terapia_intensiva"],
    totaleOspedalizzati:       json["totale_ospedalizzati"],
    isolamentoDomiciliare:     json["isolamento_domiciliare"],
    totaleAttualmentePositivi: json["totale_attualmente_positivi"],
    nuoviAttualmentePositivi:  json["nuovi_attualmente_positivi"],
    dimessiGuariti:            json["dimessi_guariti"],
    deceduti:                  json["deceduti"],
    totaleCasi:                json["totale_casi"],
    tamponi:                   json["tamponi"],
  );

  @override
  String toString() {
    return
      "[${this.data}] ${this.denominazioneRegione}: " +
          "positivi: ${this.totaleAttualmentePositivi} " +
          "guariti: ${this.dimessiGuariti} " +
          "deceduti: ${this.deceduti}";
  }
}