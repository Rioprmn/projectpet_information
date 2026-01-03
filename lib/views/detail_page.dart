import 'package:flutter/material.dart';
import '../models/animal_model.dart';

class DetailPage extends StatefulWidget { // Ubah ke StatefulWidget untuk handle state favorit lokal
  final Animal animal;

  const DetailPage({super.key, required this.animal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false; // Status favorit lokal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Fitur 2: Tombol Favorite di Detail Page
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFavorite 
                    ? "${widget.animal.name} ditambah ke Favorit" 
                    : "Dihapus dari Favorit"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          // Tombol Share (Opsional, tapi keren buat fitur tambahan)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Logika share bisa ditambah nanti
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'photo-${widget.animal.name}', 
              child: Image.network(
                widget.animal.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    Container(height: 300, color: Colors.grey, child: const Icon(Icons.pets, size: 100)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.animal.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.animal.latinName,
                    style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text(
                    "Status Konservasi:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(widget.animal.status, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deskripsi:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.animal.description, 
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}