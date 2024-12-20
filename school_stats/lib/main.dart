import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeGridPage(),
    const VotiPage(),
    const Placeholder(), // Placeholder per "Data"
    const Placeholder(), // Placeholder per "Impostazioni"
  ];

  // Funzione per gestire il cambio di pagina tramite la barra di navigazione
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Stats'),
        backgroundColor: const Color.fromARGB(255, 252, 66, 252),
      ),
      body: _pages[_selectedIndex],
      // Barra di navigazione inferiore
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Voti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 252, 66, 252),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Pagina con la griglia (Home)
class HomeGridPage extends StatelessWidget {
  const HomeGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.pink[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'Item ${index + 1}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class VotiPage extends StatelessWidget {
  const VotiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> voti = [
      'Matematica: 8',
      'Italiano: 7',
      'Inglese: 9',
      'Scienze: 6',
      'Storia: 7',
      'Educazione Fisica: 10',
      'Arte: 8',
      'Musica: 7',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: voti.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 252, 66, 252),
              child: Text(
                voti[index][0], // Prima lettera della materia
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(voti[index]),
            subtitle: const Text('Dettaglio voto'),
          ),
        );
      },
    );
  }
}


