import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'poke_detail_page.dart';

class FavoritesListByTypePage extends StatelessWidget {
  final String typeName;

  FavoritesListByTypePage({super.key, required this.typeName});

  final Map<String, Color> typeColors = {
    'fire': Colors.red,
    'water': Colors.blue,
    'grass': Colors.green,
    'electric': Colors.amber,
    'psychic': Colors.purple,
    'ice': Colors.cyan,
    'ground': Colors.brown,
    'rock': Colors.grey,
    'flying': Colors.indigo,
    'bug': Colors.lightGreen,
    'poison': Colors.deepPurple,
    'ghost': Colors.deepPurpleAccent,
    'dragon': Colors.indigoAccent,
    'dark': Colors.black87,
    'fairy': Colors.pinkAccent,
    'normal': Colors.black54,
    'fighting': Colors.orange,
    'steel': Colors.blueGrey,
    'stellar': Colors.deepPurple,
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver favoritos.')),
      );
    }

    final typeColor = typeColors[typeName.toLowerCase()] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: typeColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Favoritos de tipo ${typeName.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'PokemonSolid',
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .where('types', arrayContains: typeName.toLowerCase())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay Pokémon favoritos de este tipo',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final raw = docs[index].data() as Map<String, dynamic>;
              final types = List<String>.from(raw['types'] ?? []);
              final primaryType = types.isNotEmpty ? types[0].toLowerCase() : 'normal';
              final color = typeColors[primaryType] ?? Colors.grey;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PokemonDetailPage(pokemon: raw),
                    ),
                  );
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
                      Image.network(raw['image'], height: 80, fit: BoxFit.contain),
                      const SizedBox(height: 12),
                      Text(
                        raw['name'].toString().toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'PokemonSolid',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        types.join(', ').toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'PokemonSolid',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
