import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/animal_model.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import 'news_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pet Information - Daftar Hewan"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Berita (REST API)
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              );
            },
          ),
          // Tombol Profil (Halaman ke-6)
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Wah, ada error!"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada data hewan."));
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              String docId = document.id;
              Animal animal = Animal.fromJson(document.data() as Map<String, dynamic>);
              
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(animal: animal),
                      ),
                    );
                  },
                  onLongPress: () => _showDeleteConfirm(context, docId, animal.name),
                  leading: Hero(
                    tag: 'photo-${animal.name}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        animal.imageUrl, 
                        width: 60, 
                        height: 60, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 40),
                      ),
                    ),
                  ),
                  title: Text(animal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(animal.latinName, style: const TextStyle(fontStyle: FontStyle.italic)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditAnimalDialog(context, docId, animal),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          animal.status, 
                          style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showAddAnimalDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- FUNGSI TAMBAH DATA ---
  void _showAddAnimalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final latinController = TextEditingController();
    final statusController = TextEditingController();
    final imageController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Hewan Baru"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Hewan")),
              TextField(controller: latinController, decoration: const InputDecoration(labelText: "Nama Latin")),
              TextField(controller: statusController, decoration: const InputDecoration(labelText: "Status")),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Foto")),
              TextField(
                controller: descController, 
                maxLines: 3, 
                decoration: const InputDecoration(labelText: "Deskripsi Singkat")
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('animals').add({
                  'name': nameController.text,
                  'latin_name': latinController.text,
                  'status': statusController.text,
                  'image_url': imageController.text,
                  'description': descController.text,
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI EDIT DATA ---
  void _showEditAnimalDialog(BuildContext context, String docId, Animal animal) {
    final nameController = TextEditingController(text: animal.name);
    final latinController = TextEditingController(text: animal.latinName);
    final statusController = TextEditingController(text: animal.status);
    final imageController = TextEditingController(text: animal.imageUrl);
    final descController = TextEditingController(text: animal.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Data Hewan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Hewan")),
              TextField(controller: latinController, decoration: const InputDecoration(labelText: "Nama Latin")),
              TextField(controller: statusController, decoration: const InputDecoration(labelText: "Status")),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Foto")),
              TextField(
                controller: descController, 
                maxLines: 3, 
                decoration: const InputDecoration(labelText: "Deskripsi")
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('animals').doc(docId).update({
                'name': nameController.text,
                'latin_name': latinController.text,
                'status': statusController.text,
                'image_url': imageController.text,
                'description': descController.text,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI HAPUS DATA ---
  void _showDeleteConfirm(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: Text("Yakin ingin menghapus $name dari project pet_information?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('animals').doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}