import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'news_detail.dart'; // Pastikan file ini sudah kamu buat

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<dynamic>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchNews();
  }

  // Ambil data dari npoint.io (Paling Aman & Stabil)
  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.npoint.io/79589d4930b56adc5c24'),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat berita: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: () async {
          setState(() {
            _newsFuture = fetchNews();
          });
        },
        child: CustomScrollView(
          slivers: [
            // Header yang bisa mengecil (Sliver)
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  "BERITA KONSERVASI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    fontSize: 16,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.green, Color(0xFF1B5E20)],
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.green,
              elevation: 0,
            ),

            // List Berita
            FutureBuilder<List<dynamic>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(child: _buildErrorState());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("Tidak ada berita tersedia.")),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildNewsCard(snapshot.data![index]);
                    }, childCount: snapshot.data!.length),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(dynamic news) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () {
          // NAVIGASI KE DETAIL (Penting!)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewsDetailPage(news: news)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      news['image'] ?? 'https://via.placeholder.com/400x200',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(230),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "INFO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Info Tanggal
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "Baru saja • 5 mnt baca",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Judul
            Text(
              news['title'] ?? 'Tanpa Judul',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            // Deskripsi
            Text(
              news['description'] ?? 'Tidak ada deskripsi.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Koneksi Bermasalah",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "Tarik layar untuk mencoba lagi",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
