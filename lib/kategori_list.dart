import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti_app/main.dart';
import 'package:flutter_not_sepeti_app/utils/dabase_halper.dart';

import 'models/kategoriler.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori> tumKategoriListesi;
  DatabaseHalper _databaseHalper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseHalper = DatabaseHalper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriListesi == null) {
      tumKategoriListesi = List<Kategori>();
      kategoriListesiniGuncelle();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Kategoriler"),
        ),
        body: ListView.builder(
            itemCount: tumKategoriListesi.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  _KategoriGuncelle(tumKategoriListesi[index], context);
                },
                title: Text(tumKategoriListesi[index].kategoriBaslik),
                trailing: GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    _KategoriSil(tumKategoriListesi[index].kategoriId);
                  },
                ),
                leading: Icon(Icons.category),
              );
            }));
  }

  void kategoriListesiniGuncelle() {
    _databaseHalper.listeKategorileriGetir().then((kategoriList) {
      setState(() {
        tumKategoriListesi = kategoriList;
      });
    });
  }

  void _KategoriSil(int kategoriId2) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Emin Misiniz"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Kategori Silinince kategori ile ilgili tüm notlar silinecektir"),
                ButtonBar(
                  children: [
                    TextButton(
                        onPressed: () {
                          _databaseHalper
                              .kategoriSil(kategoriId2)
                              .then((silinenId) {
                            if (silinenId != 0) {
                              setState(() {
                                kategoriListesiniGuncelle();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MyApp()));
                              });
                            }
                          });
                        },
                        child: Text(
                          "Sil",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Vazgec",
                          style: TextStyle(color: Colors.orange),
                        )),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _KategoriGuncelle(Kategori guncellenecekKategori, BuildContext c) {
    kategoriGuncelleDialog(c, guncellenecekKategori);
  }
}

void kategoriGuncelleDialog(
    BuildContext myContext, Kategori guncellenecekKategori) {
  var formKey = GlobalKey<FormState>();
  var _textController = TextEditingController();
  DatabaseHalper _databaseHalper;
  _databaseHalper = DatabaseHalper();
  var GuncellenecekKategoriAdi;
  print(guncellenecekKategori.kategoriBaslik);
  showDialog(
      barrierDismissible: false,
      context: myContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Kategori Güncelle",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: guncellenecekKategori.kategoriBaslik,
                  // controller: _textController,
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
                    GuncellenecekKategoriAdi = kategori;
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
                          .kategoriGuncelle(Kategori.withId(
                              guncellenecekKategori.kategoriId,
                              GuncellenecekKategoriAdi))
                          .then((katID) {
                        if (katID != 0) {
                          ScaffoldMessenger.of(myContext).showSnackBar(
                            SnackBar(
                              content: Text("Kategori Güncellendi"),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Kategoriler()));
                        }
                      });
                      /*  _databaseHalper
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
                      });*/
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
