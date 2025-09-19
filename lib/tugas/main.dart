import 'dart:convert';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Game FreeToGame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Daftar Game (FreeToGame API)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List dataGame = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  /// Fungsi ambil data dari API FreeToGame
  Future<void> _ambilData() async {
    try {
      final url = kIsWeb
          ? 'https://cors-anywhere.herokuapp.com/https://www.freetogame.com/api/games'
          : 'https://www.freetogame.com/api/games';

      final response = await http.get(
        Uri.parse(url),
        headers: {"Access-Control-Allow-Origin": "*"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // Simpan hanya 20 data pertama
          dataGame = data.take(20).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal load data. Code: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _loading = false;
      });
    }
  }

  /// helper untuk gambar
  String proxyImage(String url) {
    if (kIsWeb) {
      return "https://cors-anywhere.herokuapp.com/$url";
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber, title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : ListView.builder(
                itemCount: dataGame.length,
                itemBuilder: (context, index) {
                  final game = dataGame[index];
                  return _listItem(
                    proxyImage(
                      game['thumbnail'] ?? 'https://via.placeholder.com/150',
                    ),
                    game['title'] ?? 'Tanpa Judul',
                    game['genre'] ?? 'Tidak ada genre',
                    game['release_date'] ?? 'Tidak ada tanggal',
                    game['game_url'] ?? '',
                  );
                },
              ),
      ),
    );
  }
}

/// 🔹 Fungsi untuk tombol "Baca Info"
Widget _tombolBaca(String url) {
  return InkWell(
    onTap: () {
      debugPrint("Klik Baca Info: $url");
      // 👉 kalau mau buka link asli, bisa tambahkan package url_launcher
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text('Baca Info', style: TextStyle(color: Colors.white)),
    ),
  );
}

/// 🔹 Fungsi untuk item list game
Container _listItem(
  String url,
  String judul,
  String genre,
  String rilis,
  String linkGame,
) {
  return Container(
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(url, width: 70, height: 70, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(genre, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(rilis, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  _tombolBaca(linkGame),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
