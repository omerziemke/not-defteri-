import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_not_sepeti_app/kategori_list.dart';
import 'package:flutter_not_sepeti_app/models/kategoriler.dart';
import 'package:flutter_not_sepeti_app/utils/dabase_halper.dart';

import 'models/not.dart';
import 'not_detay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  DatabaseHalper _databaseHalper = DatabaseHalper();

  var _scoffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scoffold,
      appBar: AppBar(
        title: Center(child: Text("Not Sepeti")),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _kategoriSayfasiGit(context);
                    },
                    leading: Icon(Icons.category),
                    title: Text("Kategoriler"),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "kategoriEkle",
            tooltip: "Kategori ekle",
            onPressed: () {
              kategoriEkleDialog(context);
            },
            child: Icon(Icons.add_circle),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: "notEkle",
            tooltip: "not ekle",
            onPressed: () => _NotDetaySayfasinaGit(context),
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    var _textController = TextEditingController();
    var yeniKategoriAdi;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _textController,
                    autovalidate: true,
                    decoration: InputDecoration(
                      labelText: "Kategori",
                      hintText: "Kategori Giriniz..",
                      //  border: OutlineInputBorder(),
                    ),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi.length < 2) {
                        return "En az 2 karakter giriniz";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (kategori) {
                      yeniKategoriAdi = kategori;
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        _databaseHalper
                            .kategoriEkle(Kategori(_textController.text))
                            .then((kategoriId) {
                          if (kategoriId > 0) {
                            _scoffold.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Kategori Eklendi"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            _scoffold.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Hata"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Vazgec",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.deepOrange,
                  ),
                ],
              ),
            ],
          );
        });
  }

  _NotDetaySayfasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                NotDetay(baslik: "Yeni Not"))).then((value) => setState(() {}));
  }

  void _kategoriSayfasiGit(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Kategoriler()));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHalper _databaseHalper;
  DateTime tempDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseHalper = DatabaseHalper();
    tumNotlar = List<Not>();
  }

  @override
  Widget build(BuildContext context) {
    print("calıştııııı");
    return FutureBuilder(
        future: _databaseHalper.notListesi(),
        builder: (context, AsyncSnapshot<List<Not>> notListem) {
          if (notListem.connectionState == ConnectionState.done) {
            tumNotlar = notListem.data;
            sleep(Duration(microseconds: 500));
            return ListView.builder(
                itemCount: tumNotlar.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    leading: _oncelikIconuEkle(tumNotlar[index].notOncelik),
                    title: Text(tumNotlar[index].notBaslik),
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Kategori",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    tumNotlar[index].kategoriBaslik,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Olusturulma Tarihi",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _databaseHalper.dateFormat(DateTime.parse(
                                        tumNotlar[index].notTarih)),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "Icerik \n" + tumNotlar[index].notIcerik),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextButton(
                                  onPressed: () => _NotDetaySayfasinaGit(
                                      context, tumNotlar[index]),
                                  child: Text(
                                    "Güncelle",
                                    style:
                                        TextStyle(color: Colors.orangeAccent),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notId),
                                  child: Text(
                                    "Sil",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          } else {
            return Center(child: Text("Yükleniyor..."));
          }
        });
  }

  _oncelikIconuEkle(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            "AZ",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.greenAccent,
        );
        break;
      case 1:
        return CircleAvatar(
            child: Text(
              "ORT",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.yellow);
        break;
      case 2:
        return CircleAvatar(
            child: Text(
              "ACİL",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent);
        break;
    }
  }

  _notSil(int notId) {
    print(notId);
    _databaseHalper.notSil(notId).then((value) {
      if (value != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kayit Silindi..."),
          duration: Duration(seconds: 1),
        ));
        setState(() {});
      }
    });
  }

  _guncelle(Not tumNotlar) {
    _databaseHalper.notGuncelle(tumNotlar).then((deger) {
      if (deger != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kayit Güncellendi..."),
          duration: Duration(seconds: 1),
        ));
        setState(() {});
      }
    });
  }

  _NotDetaySayfasinaGit(BuildContext context, Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Notu Düzenle",
                  duzenlenecekNot: not,
                ))).then((value) {
      setState(() {});
    });
  }
}
