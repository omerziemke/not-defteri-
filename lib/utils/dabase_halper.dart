import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_not_sepeti_app/models/kategoriler.dart';
import 'package:flutter_not_sepeti_app/models/not.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHalper {
  static DatabaseHalper _databaseHalper;
  static Database _database;

  factory DatabaseHalper() {
    if (_databaseHalper == null) {
      _databaseHalper = DatabaseHalper._internal();
      return _databaseHalper;
    } else {
      return _databaseHalper;
    }
  }
  DatabaseHalper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    print(databasesPath);
    var path = join(databasesPath, "notlarim.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notlar.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    return await openDatabase(path,
        readOnly: false); //readOnly sadece okuma yap diyo
  }

  Future<List<Map<String, dynamic>>> kategorileriGetir() async {
    var db = await _getDatabase();
    var sonuc = await db.query("kategoriler");
    return sonuc;
  }

  Future<List<Kategori>> listeKategorileriGetir() async {
    var kategorilerMapListesi = await kategorileriGetir();
    var KategoriListesi = List<Kategori>();
    for (Map kategoriMap in kategorilerMapListesi) {
      KategoriListesi.add(Kategori.fromMap(kategoriMap));
    }
    return KategoriListesi;
  }

  Future<int> kategoriEkle(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = db.insert("kategoriler", kategori.toMap());
    return sonuc;
  }

  Future<int> kategoriGuncelle(Kategori kategori) async {
    var db = await _getDatabase();
    var sonuc = db.update("kategoriler", kategori.toMap(),
        where: "kategoriId= ? ", whereArgs: [kategori.kategoriId]);
    return sonuc;
  }

  Future<int> kategoriSil(int kategoriId) async {
    var db = await _getDatabase();
    var sonuc = db.delete("kategoriler",
        where: "kategoriId= ? ", whereArgs: [kategoriId]);
    return sonuc;
  }

  //////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////NOTLAR İÇİN////////////////////////////////////
  Future<List<Map<String, dynamic>>> notlarGetir() async {
    var db = await _getDatabase();
    var sonuc = await db.rawQuery(
        'SELECT *FROM "not" INNER JOIN kategoriler on kategoriler.kategoriId="not".kategoriId order by notId Desc ');
    return sonuc;
  }

  Future<List<Not>> notListesi() async {
    var notListesiMap = await notlarGetir();
    var notListesi = List<Not>();
    for (Map map in notListesiMap) {
      notListesi.add(Not.fromMap(map));
    }
    return notListesi;
  }

  Future<int> notEkle(Not not) async {
    var db = await _getDatabase();
    var sonuc = db.insert("not", not.toMap());
    return sonuc;
  }

  Future<int> notGuncelle(Not not) async {
    var db = await _getDatabase();
    var sonuc = db
        .update("not", not.toMap(), where: "notId= ? ", whereArgs: [not.notId]);
    return sonuc;
  }

  Future<int> notSil(int notId) async {
    var db = await _getDatabase();
    var sonuc = db.delete("not", where: "notId= ? ", whereArgs: [notId]);
    return sonuc;
  }

  String dateFormat(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "Ocak";
        break;
      case 2:
        month = "Şubat";
        break;
      case 3:
        month = "Mart";
        break;
      case 4:
        month = "Nisan";
        break;
      case 5:
        month = "Mayıs";
        break;
      case 6:
        month = "Haziran";
        break;
      case 7:
        month = "Temmuz";
        break;
      case 8:
        month = "Ağustos";
        break;
      case 9:
        month = "Eylük";
        break;
      case 10:
        month = "Ekim";
        break;
      case 11:
        month = "Kasım";
        break;
      case 12:
        month = "Aralık";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Pazartesi";
        case 2:
          return "Salı";
        case 3:
          return "Çarşamba";
        case 4:
          return "Perşembe";
        case 5:
          return "Cuma";
        case 6:
          return "Cumartesi";
        case 7:
          return "Pazar";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
}
