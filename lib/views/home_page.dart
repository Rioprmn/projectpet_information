import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/animal_model.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import 'news_page.dart';
import 'favorite_page.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  List<String> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds = prefs.getStringList('fav_pets') ?? [];
    });
  }

  Future<void> _toggleFavorite(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteIds.contains(docId)) {
        favoriteIds.remove(docId);
      } else {
        favoriteIds.add(docId);
      }
    });
    await prefs.setStringList('fav_pets', favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan DefaultTabController untuk Kategori
    return DefaultTabController(
      length: 3, // 3 Tab: Semua, Dilindungi, Biasa
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pet Information"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110), // Tinggi ditambah untuk TabBar
            child: Column(
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Cari nama hewan...",
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // TAB BAR KATEGORI
                const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: "Semua"),
                    Tab(text: "Dilindungi"),
                    Tab(text: "Biasa"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            // TOMBOL MENU FAVORIT
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const FavoritePage())
              ).then((_) => _loadFavorites()), // Refresh saat balik
            ),
            IconButton(
              icon: const Icon(Icons.newspaper),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsPage())),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildAnimalList("Semua"),
            _buildAnimalList("Dilindungi"),
            _buildAnimalList("Biasa"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => _showAddAnimalDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // WIDGET UNTUK MEMBANGUN LIST BERDASARKAN KATEGORI
  Widget _buildAnimalList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('animals').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // Filter 1: Search & Filter 2: Kategori
        var docs = snapshot.data!.docs.where((doc) {
          var name = doc['name'].toString().toLowerCase();
          var status = doc['status'].toString().toLowerCase();
          
          bool matchesSearch = name.contains(searchQuery);
          bool matchesCategory = true;

          if (category == "Dilindungi") {
            matchesCategory = status.contains("lindungi"); // Asumsi kata kunci di Firebase
          } else if (category == "Biasa") {
            matchesCategory = !status.contains("lindungi");
          }

          return matchesSearch && matchesCategory;
        }).toList();

        if (docs.isEmpty) return const Center(child: Text("Tidak ada data."));

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            String docId = docs[index].id;
            Animal animal = Animal.fromJson(docs[index].data() as Map<String, dynamic>);
            bool isFav = favoriteIds.contains(docId);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPage(animal: animal)),
                ).then((_) => _loadFavorites()),
                leading: Hero(
                  tag: 'photo-${animal.name}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(animal.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                ),
                title: Text(animal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(animal.status, style: TextStyle(color: animal.status.contains("lindungi") ? Colors.red : Colors.green)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                      onPressed: () => _toggleFavorite(docId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditAnimalDialog(context, docId, animal),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- FUNGSI CRUD (TETAP SAMA SEPERTI SEBELUMNYA) ---
  // ... (Masukkan fungsi _showAddAnimalDialog, _showEditAnimalDialog, _showDeleteConfirm di sini)
  
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
              TextField(controller: statusController, decoration: const InputDecoration(labelText: "Status (Dilindungi/Biasa)")),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Foto")),
              TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: "Deskripsi")),
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
              TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: "Deskripsi")),
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

  void _showDeleteConfirm(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: Text("Yakin ingin menghapus $name?"),
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