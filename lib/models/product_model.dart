class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.images,
  });

  // Bu factory metodu, veritabanından gelen veriler eksik veya boş (null) olsa bile
  // uygulamanın çökmesini engelleyecek şekilde güncellendi.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // id alanı boş gelirse varsayılan olarak 0 değerini ata
      id: json['id'] ?? 0,

      // title alanı boş gelirse varsayılan olarak boş bir metin ata
      title: json['title'] ?? '',

      // description alanı boş gelirse varsayılan olarak boş bir metin ata
      description: json['description'] ?? '',

      // price alanı boş gelirse varsayılan olarak 0.0 değerini ata
      price: (json['price'] as num?)?.toDouble() ?? 0.0,

      // thumbnail alanı boş gelirse varsayılan olarak boş bir metin ata
      thumbnail: json['thumbnail'] ?? '',

      // *** HATANIN ÇÖZÜLDÜĞÜ YER ***
      // 'images' alanı boş (null) ise, uygulama çökmesin diye boş bir liste ([]) ata.
      // Dolu ise, gelen veriyi bir String listesine çevir.
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  // Bu metod, bir Product nesnesini veritabanına kaydedilebilecek bir formata dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
      'images': images,
    };
  }
}