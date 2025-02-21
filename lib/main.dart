import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeMaterial(),
    );
  }
}

class HomeMaterial extends StatefulWidget {
  const HomeMaterial({super.key});

  @override
  State<HomeMaterial> createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  late Future<Map<String, dynamic>> _cotacoesFuture;

  @override
  void initState() {
    super.initState();
    _cotacoesFuture = _fetchCotacoes();
  }

  Future<Map<String, dynamic>> _fetchCotacoes() async {
    try {
      final response = await http.get(
        Uri.parse('http://api.hgbrasil.com/finance/quotations?key=5324f658'),
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = json.decode(response.body);
        return data['results']['currencies'];
      } else {
        throw 'Erro ao buscar cotações: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro ao buscar cotações: $e';
    }
  }

  final Map<String, String> _moedasTraduzidas = {
    'USD': 'Dólar',
    'EUR': 'Euro',
    'GBP': 'Libra Esterlina',
    'ARS': 'Peso Argentino',
    'JPY': 'Iene Japonês',
    'CAD': 'Dólar Canadense',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações Brasil',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _cotacoesFuture = _fetchCotacoes();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _cotacoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final cotacoes = snapshot.data!;
              return _buildCotacoesView(cotacoes);
            } else {
              return const Center(child: Text('Nenhum dado disponível.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildCotacoesView(Map<String, dynamic> cotacoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainCard(cotacoes['USD']),
        const SizedBox(height: 20),
        const Text('Outras moedas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildOtherCurrencies(cotacoes),
      ],
    );
  }

  Widget _buildMainCard(Map<String, dynamic> moeda) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_moedasTraduzidas['USD']!,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('R\$ ${moeda['buy'].toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20)),
              Text(moeda['variation'].toStringAsFixed(2),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherCurrencies(Map<String, dynamic> cotacoes) {
    final otherCurrencies = ['EUR', 'GBP', 'ARS', 'JPY', 'CAD'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: otherCurrencies.map((currency) {
          final moeda = cotacoes[currency];
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100),
            child: IntrinsicHeight(
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(_moedasTraduzidas[currency]!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('R\$ ${moeda['buy'].toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(moeda['variation'].toStringAsFixed(2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}