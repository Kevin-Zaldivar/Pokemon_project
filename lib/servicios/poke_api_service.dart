import 'dart:convert';
import 'package:http/http.dart' as http;

class PokeAPIService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  static Future<List<Map<String, dynamic>>> fetchPokemonList({
    int limit = 20,
  }) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=$limit'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      // Extrae nombre y URL de detalle por Pokémon
      List<Map<String, dynamic>> pokemons = [];

      for (var result in results) {
        final detailRes = await http.get(Uri.parse(result['url']));
        if (detailRes.statusCode == 200) {
          final detailData = json.decode(detailRes.body);
          pokemons.add({
            'name': result['name'],
            'image': detailData['sprites']['front_default'],
            'types':
                (detailData['types'] as List)
                    .map((t) => t['type']['name'].toString())
                    .toList(),
            'stats': detailData['stats'],
            'abilities': detailData['abilities'],
            'weight': detailData['weight'],
            'height': detailData['height'],
          });
        }
      }

      return pokemons;
    } else {
      throw Exception('Error al cargar Pokémon');
    }
  }
}
