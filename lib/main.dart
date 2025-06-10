import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
import 'auth_service.dart';
import 'screens/poke_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Inicializamos Firebase con opciones según la plataforma
  Future<FirebaseApp> _initializeFirebase() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        // Mostramos loading mientras inicializa Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // En caso de error
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error inicializando Firebase: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Firebase se inicializó correctamente → mostrar la app
        return MaterialApp(
          title: 'Flutter Firebase Auth',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  double _scale = 1.0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = const Color.fromARGB(255, 33, 229, 243),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${user?.displayName?.split(' ')[0] ?? 'Usuario'}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Inicio'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            Tab(icon: Icon(Icons.settings), text: 'Ajustes'),
          ],
        ),

        ///////////////
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showSnackBar(context, 'Notificaciones presionadas');
            },
          ),
          // Botón de logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 62, 150),
              ),
              accountName: Text(user?.displayName ?? 'Usuario'),
              accountEmail: Text(user?.email ?? 'email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                child:
                    user?.photoURL == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.catching_pokemon),
              title: const Text('Pokémon'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PokemonListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                _tabController.animateTo(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PerfilPage(user: user),
                  ),
                );
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                await _authService.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Primer tab - Inicio con información del usuario
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user?.photoURL != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user!.photoURL!),
                  ),
                const SizedBox(height: 20),
                Text(
                  '¡Bienvenido, ${user?.displayName ?? 'Usuario'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? 'email@example.com',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    _showSnackBar(context, 'Contenedor presionado');
                  },
                  onDoubleTap: () {
                    setState(() {
                      _scale = _scale == 1.0 ? 1.5 : 1.0;
                    });
                    _showSnackBar(
                      context,
                      'Contenedor escalado: ${_scale == 1.5 ? 'Ampliado' : 'Normal'}',
                      backgroundColor: Colors.cyan,
                    );
                  },
                  child: AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.cyan,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.touch_app,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Segundo tab - Favoritos (mantienes tu contenido actual)
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CustomCard(
                title: 'Pokemones Hielo',
                description: 'Favoritos de tipo Hielo',
                onPressed: () {
                  _showSnackBar(
                    context,
                    'Tarjeta 1 presionada',
                    backgroundColor: Colors.lightBlue,
                  );
                },
                useIcon: true,
                icon: Icons.ac_unit,
                iconColor: Colors.lightBlue,
              ),
              const SizedBox(height: 16.0),
              CustomCard(
                title: 'Pokemones tipo Fuego',
                description: 'Favoritos de tipo Fuego',
                onPressed: () {
                  _showSnackBar(
                    context,
                    'Tarjeta 2 presionada',
                    backgroundColor: Colors.orange,
                  );
                },
                useIcon: true,
                icon: Icons.fire_extinguisher,
                iconColor: Colors.red,
              ),
              const SizedBox(height: 16.0),
              CustomCard(
                title: 'Pokemones tipo Agua',
                description: 'Favoritos de tipo Agua',
                onPressed: () {
                  _showSnackBar(
                    context,
                    'Tarjeta 3 presionada',
                    backgroundColor: Colors.blue,
                  );
                },
                useIcon: true,
                icon: Icons.water,
                iconColor: Colors.blue,
              ),
            ],
          ),
          // Tercer tab - Ajustes
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pantalla de Ajustes',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showSnackBar(
                      context,
                      'Ajustes guardados',
                      backgroundColor: Colors.green,
                    );
                  },
                  child: const Text('Guardar ajustes'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSnackBar(
            context,
            'FloatingActionButton presionado en Tab: ${_tabController.index + 1}',
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar',
      ),
    );
  }
}

// Widget personalizado (CustomCard)
class CustomCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;
  final bool useIcon;
  final IconData icon;
  final Color iconColor;

  const CustomCard({
    Key? key,
    required this.title,
    required this.description,
    required this.onPressed,
    this.useIcon = false,
    this.icon = Icons.star,
    this.iconColor = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (useIcon)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10.0),
                  ),
                ),
                child: Icon(icon, size: 60, color: iconColor),
                alignment: Alignment.center,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerfilPage extends StatelessWidget {
  final User? user;

  const PerfilPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user?.photoURL != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'Usuario sin nombre',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(user?.email ?? 'Correo no disponible'),
              const SizedBox(height: 20),
              Text(
                'UID: ${user?.uid ?? 'N/A'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
