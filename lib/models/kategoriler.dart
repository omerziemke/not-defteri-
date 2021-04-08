class Kategori {
  int kategoriId;
  String kategoriBaslik;

  Kategori(
      this.kategoriBaslik); //bu kategori eklerken kullanılınır çünkü id DB tarafından otomatik oluşturulur

  Kategori.withId(
      this.kategoriId, this.kategoriBaslik); //veri tabanı okurken kullanılınır

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["kategoriId"] = kategoriId;
    map["kategoriBaslik"] = kategoriBaslik;
    return map;
  }

  Kategori.fromMap(Map<String, dynamic> map) {
    //isimlendirilmiş consracter metotlara return konmaz
    this.kategoriId = map["kategoriId"];
    this.kategoriBaslik = map["kategoriBaslik"];
  }

  @override
  String toString() {
    return 'Kategori{kategoriId: $kategoriId, kategoriBaslik: $kategoriBaslik}'; //kategori nesnesini ekrana yazdırmak istersen bu şekilde yazacak
  }
}
