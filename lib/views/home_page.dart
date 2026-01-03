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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.green,
          title: const Text(
            "Pet Information",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritePage()),
              ).then((_) => _loadFavorites()),
            ),
            IconButton(
              icon: const Icon(Icons.newspaper),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: Column(
              children: [
                // SEARCH BAR ADAPTIF
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black26 : Colors.black12,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) =>
                          setState(() => searchQuery = value.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: "Cari nama hewan...",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.green),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                // TAB BAR
                const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: "Semua"),
                    Tab(text: "Dilindungi"),
                    Tab(text: "Biasa"),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnimalList("Semua"),
            _buildAnimalList("Dilindungi"),
            _buildAnimalList("Biasa"),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          onPressed: () => _showAddAnimalDialog(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Hewan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalList(String category) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('animals').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        var docs = snapshot.data!.docs.where((doc) {
          var name = (doc['name'] ?? "").toString().toLowerCase();
          var status = (doc['status'] ?? "").toString().toLowerCase();
          bool matchesSearch = name.contains(searchQuery);
          bool matchesCategory = true;

          if (category == "Dilindungi") {
            matchesCategory = status.contains("lindungi");
          } else if (category == "Biasa") {
            matchesCategory = !status.contains("lindungi");
          }
          return matchesSearch && matchesCategory;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 80,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  "Data tidak ditemukan",
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            String docId = docs[index].id;
            Animal animal = Animal.fromJson(
              docs[index].data() as Map<String, dynamic>,
            );
            bool isFav = favoriteIds.contains(docId);
            bool isProtected = animal.status.toLowerCase().contains("lindungi");

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(animal: animal),
                  ),
                ).then((_) => _loadFavorites()),
                leading: Hero(
                  tag: 'photo-${animal.name}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(animal.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  animal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isProtected
                            ? (isDarkMode
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.red.shade50)
                            : (isDarkMode
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.green.shade50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        animal.status,
                        style: TextStyle(
                          color: isProtected ? Colors.redAccent : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => _toggleFavorite(docId),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_note,
                        color: isDarkMode ? Colors.blue[300] : Colors.blue,
                      ),
                      onPressed: () =>
                          _showEditAnimalDialog(context, docId, animal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep, color: Colors.grey),
                      onPressed: () =>
                          _showDeleteConfirm(context, docId, animal.name),
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

  // --- FUNGSI CRUD LENGKAP ---

  void _showAddAnimalDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final latinCtrl = TextEditingController();
    final statusCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Hewan Baru 🐾"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(nameCtrl, "Nama Hewan"),
              _buildInput(latinCtrl, "Nama Latin"),
              _buildInput(statusCtrl, "Status (Dilindungi/Biasa)"),
              _buildInput(imageCtrl, "URL Foto"),
              _buildInput(descCtrl, "Deskripsi", maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('animals').add({
                  'name': nameCtrl.text,
                  'latin_name': latinCtrl.text,
                  'status': statusCtrl.text,
                  'image_url': imageCtrl.text,
                  'description': descCtrl.text,
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditAnimalDialog(
    BuildContext context,
    String docId,
    Animal animal,
  ) {
    final nameCtrl = TextEditingController(text: animal.name);
    final latinCtrl = TextEditingController(text: animal.latinName);
    final statusCtrl = TextEditingController(text: animal.status);
    final imageCtrl = TextEditingController(text: animal.imageUrl);
    final descCtrl = TextEditingController(text: animal.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Data Hewan ✏️"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(nameCtrl, "Nama Hewan"),
              _buildInput(latinCtrl, "Nama Latin"),
              _buildInput(statusCtrl, "Status"),
              _buildInput(imageCtrl, "URL Foto"),
              _buildInput(descCtrl, "Deskripsi", maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('animals')
                  .doc(docId)
                  .update({
                    'name': nameCtrl.text,
                    'latin_name': latinCtrl.text,
                    'status': statusCtrl.text,
                    'image_url': imageCtrl.text,
                    'description': descCtrl.text,
                  });
              if (mounted) Navigator.pop(context);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Data? 🗑️"),
        content: Text("Yakin ingin menghapus $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('animals')
                  .doc(docId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
