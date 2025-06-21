import 'package:flutter/material.dart';
import 'package:ejercicio_clase/servicios/poke_api_service.dart';
import 'poke_detail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  List<Map<String, dynamic>> pokemonList = [];
  List<Map<String, dynamic>> filteredPokemonList = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    PokeAPIService.fetchPokemonList().then((data) {
      setState(() {
        pokemonList = data;
        filteredPokemonList = data;
        isLoading = false;
      });
    });
  }

  void filterPokemon(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPokemonList = pokemonList;
      });
      return;
    }

    final result =
        pokemonList.where((poke) {
          final name = poke['name'].toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();

    setState(() {
      filteredPokemonList = result;
    });
  }

  Future<Map<String, dynamic>> fetchPokemonDetail(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('No se pudo cargar detalles');
    }

    final data = json.decode(res.body);
    return {
      'name': data['name'],
      'image': data['sprites']['other']['official-artwork']['front_default'],
      'types':
          (data['types'] as List)
              .map((t) => t['type']['name'].toString())
              .toList(),
      'height': '${(data['height'] / 10).toStringAsFixed(1)} m',
      'weight': '${(data['weight'] / 10).toStringAsFixed(1)} kg',
      'abilities': data['abilities'],
      'stats': data['stats'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(
            top: 32,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              const Text(
                'Wikdex',
                style: TextStyle(
                  fontFamily: 'PokemonSolid',
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar Pokémon...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: filterPokemon,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        itemCount: filteredPokemonList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                        itemBuilder: (context, index) {
                          final pokemon = filteredPokemonList[index];

                          return GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              );

                              try {
                                final details = await fetchPokemonDetail(
                                  pokemon['url'],
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PokemonDetailPage(
                                            pokemon: details,
                                          ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al cargar el Pokémon'),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    pokemon['image'],
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    pokemon['name'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'PokemonSolid',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'N.º ${pokemon['id'].toString()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
