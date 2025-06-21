import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PokemonDetailPage extends StatefulWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final pokemonId =
        widget.pokemon['id']?.toString() ?? widget.pokemon['name'];
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(pokemonId);

    final doc = await docRef.get();

    print('🔎 checkFavoriteStatus → ID: $pokemonId | Existe: ${doc.exists}');

    setState(() {
      isFavorite = doc.exists;
    });
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    final pokemonId =
        widget.pokemon['id']?.toString() ?? widget.pokemon['name'];
    print('🧪 toggleFavorite → Pokémon ID: $pokemonId');

    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para agregar favoritos')),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(pokemonId);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'id': widget.pokemon['id'] ?? pokemonId,
        'name': widget.pokemon['name'],
        'image': widget.pokemon['image'],
        'types': List<String>.from(widget.pokemon['types']),
        'height': widget.pokemon['height'],
        'weight': widget.pokemon['weight'],
        'abilities': widget.pokemon['abilities'],
        'stats': widget.pokemon['stats'],
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  String formatText(String text) {
    return text
        .split('-')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static const Map<String, List<Color>> typeGradients = {
    'fire': [Colors.deepOrange, Colors.orangeAccent],
    'water': [Colors.blue, Colors.lightBlueAccent],
    'grass': [Colors.green, Colors.lightGreen],
    'electric': [Colors.amber, Colors.yellow],
    'psychic': [Colors.purple, Colors.pinkAccent],
    'ice': [Colors.cyan, Colors.lightBlueAccent],
    'ground': [Colors.brown, Colors.orange],
    'rock': [Colors.grey, Colors.blueGrey],
    'flying': [Colors.indigo, Colors.lightBlue],
    'bug': [Colors.lightGreen, Colors.greenAccent],
    'poison': [Colors.deepPurple, Colors.purpleAccent],
    'ghost': [Colors.deepPurpleAccent, Colors.indigo],
    'dragon': [Colors.indigoAccent, Colors.blue],
    'dark': [Colors.black87, Colors.grey],
    'fairy': [Colors.pinkAccent, Colors.pink],
    'normal': [Colors.grey, Colors.white],
    'fighting': [Colors.deepOrange, Colors.red],
    'steel': [Colors.blueGrey, Colors.grey],
  };

  @override
  Widget build(BuildContext context) {
    final types = List<String>.from(widget.pokemon['types']);
    final primaryType = types.isNotEmpty ? types[0].toLowerCase() : 'normal';
    final colors = typeGradients[primaryType] ?? [Colors.grey, Colors.white];
    final typeColor = colors[0];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            widget.pokemon['name'].toString().toUpperCase(),
            style: const TextStyle(fontFamily: 'PokemonSolid'),
          ),
          backgroundColor: typeColor.withOpacity(0.9),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.network(widget.pokemon['image'], height: 150),
                ),
                const SizedBox(height: 20),
                Text(
                  'TIPO: ${types.join(', ').toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Altura: ${widget.pokemon['height']}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      'Peso: ${widget.pokemon['weight']}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'HABILIDADES',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...List<Widget>.from(
                  (widget.pokemon['abilities'] as List).map(
                    (ab) => Text(
                      formatText(ab['ability']['name']),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ESTADÍSTICAS',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...List<Widget>.from(
                  (widget.pokemon['stats'] as List).map((s) {
                    final statName = formatText(s['stat']['name']);
                    final statValue = s['base_stat'] as int;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              statName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    blurRadius: 3,
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: LinearProgressIndicator(
                              value: statValue / 150,
                              backgroundColor: Colors.white24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statValue.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: toggleFavorite,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                    child: Image.asset(
                      isFavorite
                          ? 'assets/icons/pokeball_closed.png'
                          : 'assets/icons/pokeball_open.png',
                      key: ValueKey(isFavorite),
                      width: 28,
                    ),
                  ),
                  label: Text(
                    isFavorite ? 'Favorito guardado' : 'Agregar a favoritos',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFavorite ? Colors.redAccent : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
