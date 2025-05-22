import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Agenda",
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _currentIndex = _tabController.index;
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
    Color backgroundColor = Colors.greenAccent,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.black,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi agenda personal"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home_work), text: "Tareas"),
            Tab(icon: Icon(Icons.note_add_sharp), text: "Notas"),
            Tab(icon: Icon(Icons.contact_page), text: "Contactos"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showSnackBar(context, 'Notificaciones han sido presionadas');
            },
          ),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [TareasTab(), NotasTab(), ContactosTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSnackBar(
            context,
            'Floating ha sido presionado en la tab: ${_tabController.index + 1}',
          );
        },
        child: const Icon(Icons.add),
        tooltip: "Agregar",
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_work),
              title: const Text("Tareas"),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text("Notas"),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text("Contactos"),
              onTap: () {
                _tabController.animateTo(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

//--------------------TAREAS------------------------
class TareasTab extends StatefulWidget {
  const TareasTab({super.key});

  @override
  State<TareasTab> createState() => _TareasTabState();
}

class _TareasTabState extends State<TareasTab> {
  final List<Map<String, dynamic>> tareas = [
    {
      'titulo': 'Examen de Programacion Movil',
      'descripcion':
          'Repasar teoria y practicar con ejercicios en flutter para mi examen',
      'completada': false,
    },
    {
      'titulo': 'Trabajo en clase',
      'descripcion': 'Trabajo en clase, se entrega el jueves 22 de mayo',
      'completada': false,
    },
    {
      'titulo': 'Tarea 4 Fisica',
      'descripcion': 'Tarea Leyes de Newton, se entrega el domingo 25 de mayo',
      'completada': false,
    },
  ];

  void _toggleTarea(int index) {
    setState(() {
      tareas[index]['completada'] = !(tareas[index]['completada'] as bool);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tareas[index]['completada'] ? 'Tarea completada' : 'Tarea pendiente',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        final tarea = tareas[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
                tarea['completada']
                    ? const Color.fromARGB(255, 143, 215, 145)
                    : Colors.red[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              tarea['titulo'],
              style: TextStyle(
                decoration:
                    tarea['completada']
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(tarea['descripcion']),
            trailing: Icon(
              tarea['completada']
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: tarea['completada'] ? Colors.green : Colors.red,
            ),
            onTap: () => _toggleTarea(index),
          ),
        );
      },
    );
  }
}

//----------------NOTAS------------------
class NotasTab extends StatefulWidget {
  const NotasTab({Key? key}) : super(key: key);

  @override
  State<NotasTab> createState() => _NotasTabState();
}

class _NotasTabState extends State<NotasTab> {
  final List<bool> _agrandada = [false, false];

  void _toggleZoom(int index) {
    setState(() {
      _agrandada[index] = !_agrandada[index];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_agrandada[index] ? 'Nota agrandada' : 'Nota reducida'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        GestureDetector(
          onDoubleTap: () => _toggleZoom(0),
          child: NotaCard(
            titulo: "Recordar Clase de Programacion Movil",
            contenido: "Clase de Programacion Movil, sabados 1:30 PM",
            agrandada: _agrandada[0],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onDoubleTap: () => _toggleZoom(1),
          child: NotaCard(
            titulo: "Ideas de proyecto",
            contenido: "Aplicación, proyecto de cartas pokemon.",
            agrandada: _agrandada[1],
          ),
        ),
      ],
    );
  }
}

class NotaCard extends StatelessWidget {
  final String titulo;
  final String contenido;
  final bool agrandada;

  const NotaCard({
    Key? key,
    required this.titulo,
    required this.contenido,
    required this.agrandada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            agrandada
                ? [
                  BoxShadow(
                    color: Colors.amber.shade300,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      width: double.infinity,
      height: agrandada ? 200 : 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              contenido,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}

//-----------------------CONTACTOS--------------------------
class ContactosTab extends StatefulWidget {
  const ContactosTab({Key? key}) : super(key: key);

  @override
  State<ContactosTab> createState() => _ContactosTabState();
}

class _ContactosTabState extends State<ContactosTab> {
  final List<Map<String, String>> _contactos = [
    {'nombre': 'Kevin Zaldívar', 'telefono': '9876-5432'},
    {'nombre': 'Fabio Lagos', 'telefono': '9988-1122'},
    {'nombre': 'Nelson Acosta', 'telefono': '9486-1378'},
  ];

  void _guardarCambios() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados correctamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _contactos.length,
            itemBuilder: (context, index) {
              final contacto = _contactos[index];
              return ContactoCard(
                nombre: contacto['nombre']!,
                telefono: contacto['telefono']!,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _guardarCambios,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class ContactoCard extends StatelessWidget {
  final String nombre;
  final String telefono;

  const ContactoCard({Key? key, required this.nombre, required this.telefono})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(nombre),
        subtitle: Text("Teléfono: $telefono"),
      ),
    );
  }
}
