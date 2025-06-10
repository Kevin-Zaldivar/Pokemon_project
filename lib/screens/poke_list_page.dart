import 'package:flutter/material.dart';
import 'package:ejercicio_clase/servicios/poke_api_service.dart';
import 'poke_detail_page.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  List<Map<String, dynamic>> pokemonList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    PokeAPIService.fetchPokemonList().then((data) {
      setState(() {
        pokemonList = data;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: pokemonList.length,
                itemBuilder: (context, index) {
                  final pokemon = pokemonList[index];
                  return ListTile(
                    leading: Image.network(pokemon['image']),
                    title: Text(pokemon['name'].toString().toUpperCase()),
                    subtitle: Text("Tipo: ${pokemon['types'].join(', ')}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PokemonDetailPage(pokemon: pokemon),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
