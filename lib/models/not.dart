class Not {
  int notId;
  int kategoriId;
  String kategoriBaslik;
  String notBaslik;
  String notIcerik;
  String notTarih;
  int notOncelik;

  Not(this.kategoriId, this.notBaslik, this.notIcerik, this.notTarih,
      this.notOncelik); //bu kategori eklerken kullanılınır çünkü id DB tarafından otomatik oluşturulur

  Not.withId(this.notId, this.kategoriId, this.notBaslik, this.notIcerik,
      this.notTarih, this.notOncelik); //okunurken kullanılınır

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["notId"] = notId;
    map["kategoriId"] = kategoriId;
    map["notBaslik"] = notBaslik;
    map["notIcerik"] = notIcerik;
    map["notTarih"] = notTarih;
    map["notOncelik"] = notOncelik;
    return map;
  }

  Not.fromMap(Map<String, dynamic> map) {
    this.notId = map["notId"];
    this.kategoriId = map["kategoriId"];
    this.kategoriBaslik = map["kategoriBaslik"];
    this.notBaslik = map["notBaslik"];
    this.notIcerik = map["notIcerik"];
    this.notTarih = map["notTarih"];
    this.notOncelik = map["notOncelik"];
  }

  @override
  String toString() {
    return 'Not{notId: $notId, kategoriId: $kategoriId, notBaslik: $notBaslik, notIcerik: $notIcerik, notTarih: $notTarih, notOncelik: $notOncelik}';
  } //veri tabanı okurken kullanılınır

}
