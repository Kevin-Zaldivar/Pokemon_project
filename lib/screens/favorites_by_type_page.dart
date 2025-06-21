import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'favorites_list_by_type_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ... resto de imports
class FavoritesByTypePage extends StatefulWidget {
  const FavoritesByTypePage({super.key});

  @override
  State<FavoritesByTypePage> createState() => _FavoritesByTypePageState();
}

class _FavoritesByTypePageState extends State<FavoritesByTypePage> {
  int tappedIndex = -1;

  final List<Map<String, dynamic>> pokemonTypes = [
    {'name': 'normal', 'label': 'Normal', 'color': Colors.grey},
    {'name': 'fire', 'label': 'Fuego', 'color': Colors.deepOrange},
    {'name': 'water', 'label': 'Agua', 'color': Colors.blue},
    {'name': 'electric', 'label': 'Eléctrico', 'color': Colors.amber},
    {'name': 'grass', 'label': 'Planta', 'color': Colors.green},
    {'name': 'ice', 'label': 'Hielo', 'color': Colors.cyan},
    {'name': 'fighting', 'label': 'Lucha', 'color': Colors.orange},
    {'name': 'poison', 'label': 'Veneno', 'color': Colors.deepPurple},
    {'name': 'ground', 'label': 'Tierra', 'color': Colors.brown},
    {'name': 'flying', 'label': 'Volador', 'color': Colors.indigo},
    {'name': 'psychic', 'label': 'Psíquico', 'color': Colors.pinkAccent},
    {'name': 'bug', 'label': 'Bicho', 'color': Colors.lightGreen},
    {'name': 'rock', 'label': 'Roca', 'color': Colors.blueGrey},
    {'name': 'ghost', 'label': 'Fantasma', 'color': Colors.deepPurpleAccent},
    {'name': 'dragon', 'label': 'Dragón', 'color': Colors.indigoAccent},
    {'name': 'dark', 'label': 'Siniestro', 'color': Colors.black87},
    {'name': 'steel', 'label': 'Acero', 'color': Colors.blueGrey},
    {'name': 'fairy', 'label': 'Hada', 'color': Colors.pink},
    {'name': 'stellar', 'label': 'Estelar', 'color': Colors.deepPurple},
  ];

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'electric':
        return Icons.flash_on;
      case 'grass':
        return Icons.eco;
      case 'ice':
        return Icons.ac_unit;
      case 'psychic':
        return Icons.visibility;
      case 'fighting':
        return Icons.sports_mma;
      case 'poison':
        return Icons.science;
      case 'ground':
        return Icons.terrain;
      case 'flying':
        return Icons.air;
      case 'bug':
        return Icons.bug_report;
      case 'rock':
        return Icons.landscape;
      case 'ghost':
        return Icons.nightlight;
      case 'dragon':
        return Icons.whatshot;
      case 'dark':
        return Icons.dark_mode;
      case 'steel':
        return Icons.construction;
      case 'fairy':
        return Icons.auto_awesome;
      case 'normal':
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tus favoritos')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
        title: const Text(
          'Favoritos por tipo',
          style: TextStyle(
            fontFamily: 'PokemonSolid',
            fontSize: 22,
            letterSpacing: 1,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                offset: Offset(2, 2),
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('favorites')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final Map<String, int> favoritesCount = {};
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final types = List<String>.from(data['types']);
            if (types.isEmpty) continue;
            final primaryType = types[0].toLowerCase();
            favoritesCount[primaryType] =
                (favoritesCount[primaryType] ?? 0) + 1;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: pokemonTypes.length,
            itemBuilder: (context, index) {
              final type = pokemonTypes[index];
              final name = type['name'];
              final label = type['label'];
              final color = type['color'] as Color;
              final count = favoritesCount[name] ?? 0;
              final isDisabled = count == 0;

              return GestureDetector(
                onTapDown: (_) => setState(() => tappedIndex = index),
                onTapUp: (_) => setState(() => tappedIndex = -1),
                onTapCancel: () => setState(() => tappedIndex = -1),
                onTap:
                    isDisabled
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      FavoritesListByTypePage(typeName: name),
                            ),
                          );
                        },
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: tappedIndex == index ? 0.96 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.85),
                          color.withOpacity(0.65),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getTypeIcon(name),
                            size: 34,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'PokemonSolid',
                              fontSize: 20,
                              letterSpacing: 1,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$count favorito${count == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
