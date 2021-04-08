import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti_app/models/kategoriler.dart';
import 'package:flutter_not_sepeti_app/models/not.dart';
import 'package:flutter_not_sepeti_app/utils/dabase_halper.dart';

import 'main.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  DatabaseHalper _databaseHalper;
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  int kategoriId;
  int secilenOncelik;
  String notBaslik, notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    _databaseHalper = DatabaseHalper();
    _databaseHalper.kategorileriGetir().then((kategoriIcerenMapListesi) {
      for (Map kategori in kategoriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(kategori));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriId = widget.duzenlenecekNot.kategoriId;
        secilenOncelik = widget.duzenlenecekNot.notOncelik;
      } else {
        setState(() {
          kategoriId = 1;
          secilenOncelik = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.baslik),
      ),
      body: tumKategoriler.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "Kategori :",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                          margin: EdgeInsets.only(
                              right: 8, left: 8, top: 8, bottom: 8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: kategoriItemOlustur(),
                              value: kategoriId,
                              onChanged: (secilenKategoriID) {
                                setState(() {
                                  kategoriId = secilenKategoriID;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot.notBaslik
                            : "",
                        validator: (text) {
                          if (text.length <= 4) {
                            return "Lütfen 4 haneden fazla giriniz";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (text) {
                          notBaslik = text;
                        },
                        decoration: InputDecoration(
                          hintText: "Not baslığını giriniz..",
                          labelText: "Baslik",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot.notIcerik
                            : "",
                        onSaved: (text) {
                          notIcerik = text;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Not içeriğini giriniz..",
                          labelText: "İçerik",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Öncelik :",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.redAccent, width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: _oncelik.map((oncelik) {
                                  return DropdownMenuItem<int>(
                                    value: _oncelik.indexOf(oncelik),
                                    child: Text(
                                      oncelik,
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  );
                                }).toList(),
                                value: secilenOncelik,
                                onChanged: (secilenOncelikID) {
                                  setState(() {
                                    secilenOncelik = secilenOncelikID;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Vazgec",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.redAccent,
                        ),
                        RaisedButton(
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              var suan = DateTime.now();
                              if (widget.duzenlenecekNot == null) {
                                _databaseHalper
                                    .notEkle(Not(
                                        kategoriId,
                                        notBaslik,
                                        notIcerik,
                                        suan.toString(),
                                        secilenOncelik))
                                    .then((intDegeri) {
                                  print("suan :" + suan.toString());
                                  print("suan :" +
                                      _databaseHalper.dateFormat(suan));

                                  if (intDegeri != 0) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  }
                                });
                              } else {
                                _databaseHalper
                                    .notGuncelle(Not.withId(
                                        widget.duzenlenecekNot.notId,
                                        kategoriId,
                                        notBaslik,
                                        notIcerik,
                                        suan.toString(),
                                        secilenOncelik))
                                    .then((guncellenenId) {
                                  if (guncellenenId != 0) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  }
                                });
                              }
                            }
                          },
                          child: Text(
                            "Kaydet",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.green,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriId,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  kategori.kategoriBaslik,
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ))
        .toList();
  }
}
