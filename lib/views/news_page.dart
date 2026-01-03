import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // Fungsi untuk mengambil data dari REST API
  Future<List<dynamic>> fetchNews() async {
  // Menggunakan API publik dari Mockachino atau serupa yang mendukung CORS
  final response = await http.get(Uri.parse('https://api.jsonserve.com/v1/9WvSgR'));

  if (response.statusCode == 200) {
    // API ini biasanya membungkus data dalam objek atau langsung list
    final data = json.decode(response.body);
    return data is List ? data : data['articles']; 
  } else {
    throw Exception('Gagal memuat berita');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Berita Konservasi"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Gagal mengambil berita. Pastikan internet aktif."));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var news = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: [
                      Image.network(news['image'], fit: BoxFit.cover, height: 180, width: double.infinity),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(news['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(news['desc'], maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}