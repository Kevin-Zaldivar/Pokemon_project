import 'dart:convert';
import 'package:http/http.dart' as http;

class PokeAPIService {
  static Future<List<Map<String, dynamic>>> fetchPokemonList({
    int limit = 1025,
    int offset = 0,
  }) async {
    final url = 'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener la lista de Pokémon');
    }

    final data = json.decode(response.body);
    final results = data['results'] as List;

    // Cargar solo los datos básicos (sin detalles aún)
    return results.map<Map<String, dynamic>>((item) {
      final id = int.tryParse(
        item['url'].toString().split('/').where((s) => s.isNotEmpty).last,
      );
      return {
        'id': id,
        'name': item['name'],
        'url': item['url'],
        'image':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      };
    }).toList();
  }
}
