import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/animal_model.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hewan Favorit Saya"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: favoriteIds.isEmpty
          ? const Center(child: Text("Belum ada hewan favorit."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('animals').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Filter data: Hanya ambil hewan yang ID-nya ada di favoriteIds
                var favDocs = snapshot.data!.docs.where((doc) => favoriteIds.contains(doc.id)).toList();

                return ListView.builder(
                  itemCount: favDocs.length,
                  itemBuilder: (context, index) {
                    Animal animal = Animal.fromJson(favDocs[index].data() as Map<String, dynamic>);
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(animal.imageUrl)),
                      title: Text(animal.name),
                      subtitle: Text(animal.latinName),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailPage(animal: animal)),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}