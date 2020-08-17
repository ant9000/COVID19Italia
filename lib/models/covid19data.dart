import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';

double asDouble(var value){ return double.parse(value?.toString() ?? "0"); }
int asInt(var value) { return asDouble(value).toInt(); }

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
          var sixthirtyPM = new DateTime(now.year, now.month, now.day, 18, 30);
          var stale = ((now.millisecondsSinceEpoch >= sixthirtyPM.millisecondsSinceEpoch) &&
              (jsonFile.lastModifiedSync().millisecondsSinceEpoch < sixthirtyPM.millisecondsSinceEpoch)) ||
              (now.millisecondsSinceEpoch - jsonFile.lastModifiedSync().millisecondsSinceEpoch >= 24*60*60*1000);
          if(!stale) {
            result = "CACHE";
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
          result = "GITHUB";
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
        totalePositivi:            0,
        variazioneTotalePositivi:  0,
        nuoviPositivi:             0,
        dimessiGuariti:            0,
        deceduti:                  0,
        totaleCasi:                0,
        tamponi:                   0,
        casiTestati:               0,
        note:                      "",
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
      return _records[idx].totalePositivi;
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
  final int      totalePositivi;
  final int      variazioneTotalePositivi;
  final int      nuoviPositivi;
  final int      dimessiGuariti;
  final int      deceduti;
  final int      totaleCasi;
  final int      tamponi;
  final int      casiTestati;
  final String   note;

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
    this.totalePositivi,
    this.variazioneTotalePositivi,
    this.nuoviPositivi,
    this.dimessiGuariti,
    this.deceduti,
    this.totaleCasi,
    this.tamponi,
    this.casiTestati,
    this.note,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    data:                      DateTime.parse(json["data"]),
    stato:                     json["stato"],
    codiceRegione:             asInt(json["codice_regione"]),
    denominazioneRegione:      json["denominazione_regione"],
    lat:                       asDouble(json["lat"]),
    long:                      asDouble(json["long"]),
    ricoveratiConSintomi:      asInt(json["ricoverati_con_sintomi"]),
    terapiaIntensiva:          asInt(json["terapia_intensiva"]),
    totaleOspedalizzati:       asInt(json["totale_ospedalizzati"]),
    isolamentoDomiciliare:     asInt(json["isolamento_domiciliare"]),
    totalePositivi:            asInt(json["totale_positivi"]),
    variazioneTotalePositivi:  asInt(json["variazione_totale_positivi"]),
    nuoviPositivi:             asInt(json["nuovi_positivi"]),
    dimessiGuariti:            asInt(json["dimessi_guariti"]),
    deceduti:                  asInt(json["deceduti"]),
    totaleCasi:                asInt(json["totale_casi"]),
    tamponi:                   asInt(json["tamponi"]),
    casiTestati:               asInt(json["casi_testati"]),
    note:                      json["note"] ?? "",
  );

  @override
  String toString() {
    return
      "[${this.data}] ${this.denominazioneRegione}: " +
          "positivi: ${this.totalePositivi} " +
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
      totalePositivi:            this.totalePositivi + other.totalePositivi,
      nuoviPositivi:             this.nuoviPositivi + other.nuoviPositivi,
      variazioneTotalePositivi:  this.variazioneTotalePositivi + other.variazioneTotalePositivi,
      dimessiGuariti:            this.dimessiGuariti + other.dimessiGuariti,
      deceduti:                  this.deceduti + other.deceduti,
      totaleCasi:                this.totaleCasi + other.totaleCasi,
      tamponi:                   this.tamponi + other.tamponi,
      casiTestati:               this.casiTestati + other.casiTestati,
      note:                      "",
    );
  }
}