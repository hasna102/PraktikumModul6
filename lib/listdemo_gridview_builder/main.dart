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
      title: 'Demo ListView.builder Web',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Demo ListView.builder (Web)'),
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

  /// Ambil data dari NewsAPI (ganti pakai API key milikmu)
  Future<void> _ambilData() async {
    try {
      const apiKey = "20e3f63a3b3e4756a42c8d471da61ec1";
      final url =
          "https://newsapi.org/v2/top-headlines?country=us&category=technology&apiKey=$apiKey";

      final response = await http.get(Uri.parse(url));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

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
            : ListView.builder(
                itemCount: dataBerita.length,
                itemBuilder: (context, index) {
                  final berita = dataBerita[index];

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          berita['title'] ?? "Tidak ada judul",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          berita['publishedAt'] ?? "Tidak ada data",
                          maxLines: 1,
                          style: const TextStyle(fontSize: 16),
                        ),
                        leading: Image.network(
                          berita['urlToImage'] ??
                              'http://cdn.pixabay.com/photo/2018/03/17/20/51/white-buildings-3235135_340.jpg',
                          fit: BoxFit.cover,
                          width: 100,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
