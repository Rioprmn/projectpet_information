import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_information/models/animal_model.dart';
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
    if (!mounted) return;
    setState(() {
      favoriteIds = prefs.getStringList('fav_pets') ?? [];
    });
  }

  Future<void> _toggleFavorite(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds.contains(docId)
          ? favoriteIds.remove(docId)
          : favoriteIds.add(docId);
    });
    await prefs.setStringList('fav_pets', favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _buildAppBar(isDarkMode),
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
          label: const Text("Hewan", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.green,
      title: const Text(
        "Pet Information",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritePage()),
          ).then((_) => _loadFavorites()),
        ),
        IconButton(
          icon: const Icon(Icons.newspaper, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewsPage()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Column(
          children: [
            _buildSearchBar(isDarkMode),
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
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Cari nama hewan...",
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyView(isDarkMode);
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final status = (data['status'] ?? '').toString().toLowerCase();

          final matchSearch = name.contains(searchQuery);
          bool matchCategory = true;

          if (category == "Dilindungi") {
            matchCategory = status.contains("lindungi");
          } else if (category == "Biasa") {
            matchCategory = !status.contains("lindungi");
          }

          return matchSearch && matchCategory;
        }).toList();

        if (docs.isEmpty) return _emptyView(isDarkMode);

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final docId = doc.id;
            final data = doc.data() as Map<String, dynamic>;

            // ✅ PERBAIKAN DI SINI: Samakan key JSON dengan Firestore lo
            final animal = Animal.fromJson({
              'name': data['name'] ?? '',
              'latin_name':
                  data['latin_name'] ?? '', // Pakai snake_case sesuai Firestore
              'status': data['status'] ?? '',
              'image_url':
                  data['image_url'] ?? '', // Pakai snake_case sesuai Firestore
              'description': data['description'] ?? '',
            });

            final isFav = favoriteIds.contains(docId);
            final isProtected = animal.status.toLowerCase().contains(
              "lindungi",
            );

            return _animalCard(animal, docId, isFav, isProtected, isDarkMode);
          },
        );
      },
    );
  }

  Widget _animalCard(
    Animal animal,
    String docId,
    bool isFav,
    bool isProtected,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(animal: animal)),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: animal.imageUrl.isNotEmpty
              ? Image.network(
                  animal.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 40),
                )
              : const Icon(Icons.image_not_supported, size: 40),
        ),
        title: Text(
          animal.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(animal.latinName),
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
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditAnimalDialog(context, docId, animal),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _showDeleteConfirm(context, docId, animal.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView(bool isDarkMode) {
    return Center(
      child: Text(
        "Data tidak ditemukan",
        style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey),
      ),
    );
  }

  void _showAddAnimalDialog(BuildContext context) {
    _showFormDialog(context, null);
  }

  void _showEditAnimalDialog(
    BuildContext context,
    String docId,
    Animal animal,
  ) {
    _showFormDialog(context, docId, animal: animal);
  }

  void _showFormDialog(BuildContext context, String? docId, {Animal? animal}) {
    final name = TextEditingController(text: animal?.name ?? '');
    final latin = TextEditingController(text: animal?.latinName ?? '');
    final status = TextEditingController(text: animal?.status ?? '');
    final image = TextEditingController(text: animal?.imageUrl ?? '');
    final desc = TextEditingController(text: animal?.description ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId == null ? "Tambah Hewan" : "Edit Hewan"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(name, "Nama"),
              _input(latin, "Nama Latin"),
              _input(status, "Status"),
              _input(image, "Image URL"),
              _input(desc, "Deskripsi", max: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': name.text,
                'latin_name': latin.text,
                'status': status.text,
                'image_url': image.text,
                'description': desc.text,
              };

              final ref = FirebaseFirestore.instance.collection('animals');

              docId == null
                  ? await ref.add(data)
                  : await ref.doc(docId).update(data);

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Yakin hapus $name?"),
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
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String label, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        maxLines: max,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
