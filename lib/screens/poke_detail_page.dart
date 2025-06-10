import 'package:flutter/material.dart';

class PokemonDetailPage extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemon['name'].toString().toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(pokemon['image']),
            const SizedBox(height: 16),
            Text("Altura: ${pokemon['height']}"),
            Text("Peso: ${pokemon['weight']}"),
            const SizedBox(height: 16),
            Text("Tipos: ${pokemon['types'].join(', ')}"),
            const SizedBox(height: 16),
            Text(
              "Habilidades:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...pokemon['abilities']
                .map<Widget>((ab) => Text(ab['ability']['name']))
                .toList(),
            const SizedBox(height: 16),
            Text(
              "Estadísticas:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...pokemon['stats']
                .map<Widget>(
                  (s) => Text("${s['stat']['name']}: ${s['base_stat']}"),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}
