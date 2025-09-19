import 'dart:convert';
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
      title: 'Demo GridView.builder Web',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo GridView.builder (Web)'),
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
  List dataBerita = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  /// Ambil data dari NewsAPI
  Future<void> _ambilData() async {
    const apiKey =
        "20e3f63a3b3e4756a42c8d471da61ec1"; // 🔑 Ganti dengan API key kamu
    final url =
        "https://newsapi.org/v2/top-headlines?country=us&category=technology&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          dataBerita = data['articles'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal ambil data. Code: ${response.statusCode}';
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
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.25,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: dataBerita.length,
                itemBuilder: (context, index) {
                  final berita = dataBerita[index];

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: GridTile(
                      footer: SizedBox(
                        height: 65,
                        child: GridTileBar(
                          backgroundColor: Colors.black26.withAlpha(175),
                          title: Text(
                            berita['title'] ?? 'Tanpa Judul',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      child: Image.network(
                        berita['urlToImage'] ??
                            'https://cdn.pixabay.com/photo/2018/03/17/20/51/white-buildings-3235135_960_720.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
