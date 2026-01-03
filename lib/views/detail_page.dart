import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart'; // Fitur share
import '../models/animal_model.dart';

class DetailPage extends StatefulWidget {
  final Animal animal;

  const DetailPage({super.key, required this.animal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Cek apakah hewan ini sudah ada di daftar favorit
  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('fav_pets') ?? [];
    setState(() {
      isFavorite = favList.contains(widget.animal.name);
    });
  }

  // Fungsi tambah/hapus favorit
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('fav_pets') ?? [];

    setState(() {
      if (isFavorite) {
        favList.remove(widget.animal.name);
        isFavorite = false;
      } else {
        favList.add(widget.animal.name);
        isFavorite = true;
      }
    });

    await prefs.setStringList('fav_pets', favList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? "🌟 Ditambah ke Favorit" : "💔 Dihapus dari Favorit",
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Fungsi Berbagi (Share)
  void _shareAnimalInfo() {
    Share.share(
      'Cek info hewan menarik ini di aplikasi Pet Information!\n\n'
      '🐾 Nama: ${widget.animal.name}\n'
      '🧬 Nama Latin: ${widget.animal.latinName}\n'
      '🛡️ Status: ${widget.animal.status}\n\n'
      'Deskripsi:\n${widget.animal.description}',
      subject: 'Info Hewan: ${widget.animal.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan gambar yang bisa membesar/mengecil (Sliver)
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.green,
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavorite ? Colors.red : Colors.white,
                  onPressed: _toggleFavorite,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareAnimalInfo,
                ),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'photo-${widget.animal.name}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.animal.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey,
                        child: const Icon(Icons.pets, size: 100),
                      ),
                    ),
                    // Overlay gradasi agar tombol di atas tetap terlihat
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Colors.black45, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Konten Detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.animal.name,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.animal.latinName,
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge Status Konservasi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.animal.status.toLowerCase().contains(
                                "lindungi",
                              )
                              ? Colors.red.withOpacity(0.15)
                              : Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                widget.animal.status.toLowerCase().contains(
                                  "lindungi",
                                )
                                ? Colors.red
                                : Colors.green,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.animal.status,
                          style: TextStyle(
                            color:
                                widget.animal.status.toLowerCase().contains(
                                  "lindungi",
                                )
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(thickness: 1),
                  const SizedBox(height: 15),
                  const Text(
                    "Tentang Hewan Ini",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.animal.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 50), // Ruang ekstra di bawah
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
