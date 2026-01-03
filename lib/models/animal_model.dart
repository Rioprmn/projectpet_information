class Animal {
  final String name;
  final String latinName; // Di kode kita pakai camelCase
  final String status;
  final String imageUrl;

  Animal({
    required this.name,
    required this.latinName,
    required this.status,
    required this.imageUrl,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      name: json['name'] ?? '',
      // PASTIKAN BAGIAN INI SAMA DENGAN DI FIREBASE (image_69e1a6.png)
      latinName: json['latin_name'] ?? '', 
      status: json['status'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}