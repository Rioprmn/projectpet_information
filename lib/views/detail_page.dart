import 'package:flutter/material.dart';
import '../models/animal_model.dart';

class DetailPage extends StatelessWidget {
  final Animal animal;

  const DetailPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'photo-${animal.name}', 
              child: Image.network(
                animal.imageUrl,
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
                    animal.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    animal.latinName,
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
                    label: Text(animal.status, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Deskripsi:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  // SEKARANG MENGGUNAKAN DATA DINAMIS DARI FIREBASE
                  Text(
                    animal.description, 
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