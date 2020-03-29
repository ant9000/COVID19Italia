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

  Future<String> fetchData ({bool ignorecache = false}) async {
    final dir = await getApplicationSupportDirectory();
    String result = "";

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
            result = "FROM CACHE";
            print(result);
            jsonData = jsonFile.readAsStringSync();
          }
        }
      } catch (e) {
        result = "IO ERROR: $e";
        print(result);
      }
    }

    if (jsonData == "") {
      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          result = "FETCHED FROM GITHUB";
          print(result);
          jsonData = response.body;
          jsonFile.writeAsStringSync(jsonData);
        } else {
          result = "HTTP ERROR: ${response.statusCode}";
          print(result);
        }
      }catch (e){
        result = "TCP ERROR: $e";
        print(result);
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

    _byRegion["ITALIA"] = [];
    for (var d in _byDate.keys) {
      var record = Record(
        data:                      d,
        stato:                     "ITA",
        codiceRegione:             0,
        denominazioneRegione:      "ITALIA",
        ricoveratiConSintomi:      0,
        terapiaIntensiva:          0,
        totaleOspedalizzati:       0,
        isolamentoDomiciliare:     0,
        totaleAttualmentePositivi: 0,
        nuoviAttualmentePositivi:  0,
        dimessiGuariti:            0,
        deceduti:                  0,
        totaleCasi:                0,
        tamponi:                   0,
      );
      for (var idx in _byDate[d]) {
        record = record + _records[idx];
      }
      var idx = _records.length;
      _records.add(record);
      _byDate[d].insert(0, idx);
      _byRegion[record.denominazioneRegione].add(idx);
    }

    notifyListeners();

    return result;
  }

  List<DateTime> getDays() { return List.unmodifiable(_byDate.keys); }
  List<Record> getRegions() {
    var regions = []..addAll(_byRegion.keys.where((r) => r != "ITALIA"));
    if(_byRegion.keys.contains("ITALIA")){ regions.insert(0, "ITALIA"); }
    return List.unmodifiable(regions.map((r) => _records[_byRegion[r].first]));
  }

  DateTime lastDay() { return _byDate.keys.isNotEmpty ? _byDate.keys.last : null; }

  List<Record> getDayRecords(DateTime day) {
    if (_byDate.keys.contains(day)) {
      return List.unmodifiable(_byDate[day].map((idx) => _records[idx]));
    }
    return [];
  }

  List<Record> lastDayRecords() { return getDayRecords(lastDay()); }

  List<Record> getRegionRecords(String region){
    return List.unmodifiable(_byRegion[region].map((idx) => _records[idx]));
  }

  int getLastPositives() {
    if(_byRegion.containsKey("ITALIA") && _byRegion["ITALIA"].isNotEmpty) {
      var idx = _byRegion["ITALIA"].last;
      return _records[idx].totaleAttualmentePositivi;
    }
    return null;
  }
}

@immutable
class Record {
  final DateTime data;
  final String   stato;
  final int      codiceRegione;
  final String   denominazioneRegione;
  final double   lat;
  final double   long;
  final int      ricoveratiConSintomi;
  final int      terapiaIntensiva;
  final int      totaleOspedalizzati;
  final int      isolamentoDomiciliare;
  final int      totaleAttualmentePositivi;
  final int      nuoviAttualmentePositivi;
  final int      dimessiGuariti;
  final int      deceduti;
  final int      totaleCasi;
  final int      tamponi;

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

  Record operator +(Record other) {
    return new Record(
      data:                      this.data,
      stato:                     this.stato,
      codiceRegione:             this.codiceRegione,
      denominazioneRegione:      this.denominazioneRegione,
      lat:                       this.lat,
      long:                      this.long,
      ricoveratiConSintomi:      this.ricoveratiConSintomi + other.ricoveratiConSintomi,
      terapiaIntensiva:          this.terapiaIntensiva + other.terapiaIntensiva,
      totaleOspedalizzati:       this.totaleOspedalizzati + other.totaleOspedalizzati,
      isolamentoDomiciliare:     this.isolamentoDomiciliare + other.isolamentoDomiciliare,
      totaleAttualmentePositivi: this.totaleAttualmentePositivi + other.totaleAttualmentePositivi,
      nuoviAttualmentePositivi:  this.nuoviAttualmentePositivi + other.nuoviAttualmentePositivi,
      dimessiGuariti:            this.dimessiGuariti + other.dimessiGuariti,
      deceduti:                  this.deceduti + other.deceduti,
      totaleCasi:                this.totaleCasi + other.totaleCasi,
      tamponi:                   this.tamponi + other.tamponi,
    );
  }
}