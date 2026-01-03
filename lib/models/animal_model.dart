class Animal {
  final String name;
  final String latinName;
  final String status;
  final String imageUrl;
  final String description; 
  Animal({
    required this.name,
    required this.latinName,
    required this.status,
    required this.imageUrl,
    required this.description, 
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      name: json['name'] ?? '',
      latinName: json['latin_name'] ?? '',
      status: json['status'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? 'Tidak ada deskripsi.', 
    );
  }
}