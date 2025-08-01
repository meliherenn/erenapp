class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
  });

  // API'den gelen JSON verisini Product nesnesine çevirir
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'],
    );
  }

  // Product nesnesini Firestore'a göndermek için Map'e çevirir
  // YENİ EKLENEN KISIM BURASI
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
    };
  }
}