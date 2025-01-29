import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  String? authToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    String? token = await _storage.read(key: "auth_token");

    setState(() {
      authToken = token;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      home: authToken == null ? const LoginPage() : const HomePage(),
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
    const AddVotoPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //   appBar: AppBar(
    //     // title: const Text('School Stats'),
    //     title: const Text(
    //         'School Stats',
    //         style: TextStyle(
    //           color: Colors.white,
    //           fontSize: 24,
    //           fontWeight: FontWeight.bold,
    //         ),
    //     ),
    //     backgroundColor: const Color.fromARGB(255, 249, 131, 249),
    //   ),
    appBar: AppBar(
  title: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
       Icon(
        Icons.school, 
        color: Colors.white,
      ),
       SizedBox(width: 10),
       Text(
        'School Stats',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2, 
        ),
      ),
    ],
  ),
  centerTitle: true,
  backgroundColor: const Color.fromARGB(255, 249, 91, 249), 
  elevation: 5, 
  shadowColor: Colors.purple.withOpacity(0.3), 
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
  ),
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
            icon: Icon(Icons.add_circle_outline),
            label: 'Aggiungi Voto',
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



class HomeGridPage extends StatefulWidget {
  const HomeGridPage({super.key});

  @override
  State<HomeGridPage> createState() => _HomeGridPageState();
}

class _HomeGridPageState extends State<HomeGridPage> {
  List<dynamic> items = [];
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String? token = await _storage.read(key: "auth_token");
    if (token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://184.174.34.61:20001/api/materie'),
        headers: {
          'Content-Type': 'application/json',
          'token': '9d49670969b15d3bb62296fc25e3a8b1'
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<dynamic> mat = [];
        for (var item in data['materie']) {
          mat.add({
            "nome": item['nome'],
            "media": item['media'],
            "nomeCompleto": item['nomeCompleto'],
          });
        }

        setState(() {
          items = mat;
          isLoading = false;
        });
      } else {
        throw Exception('Errore nella richiesta: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Errore: $e';
        isLoading = false;
      });
    }
  }

  Color fromStringToColor(String s) {
    int hash = 0;
    if (s.isEmpty) return const Color.fromRGBO(0, 0, 0, 0);

    for (int i = 0; i < s.length; i++) {
      hash = s.codeUnitAt(i) + ((hash << 5) - hash);
      hash = hash & hash;
    }

    String color = "";
    for (int i = 0; i < 3; i++) {
      int value = (hash >> (i * 8)) & 255;
      color += value.toRadixString(16).padLeft(2, '0');
    }

    return Color(int.parse("FF$color", radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchItems,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nessun dato disponibile',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final double progressValue = (item['media'] ?? 0) / 10;
        // final color = fromStringToColor(item["nomeCompleto"]);
        final color = progressValue*10>8.0 ? Colors.green : (progressValue*10>6.0 ? Colors.orange : Colors.red);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(45, 0, 0, 0),
                offset: Offset(-4, 4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(progressValue * 10).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 30,
                  width: 1,
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    backgroundColor: color.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 15,
                  ),
                ),
                const SizedBox(
                  height: 15,
                  width: 1,
                ),
                Text(
                  item["nome"],
                  style: TextStyle(
                    fontSize: 25,
                    color: fromStringToColor(item["nomeCompleto"]),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



class VotiPage extends StatefulWidget {
  const VotiPage({super.key});

  @override
  State<VotiPage> createState() => _VotiPageState();
}

class _VotiPageState extends State<VotiPage> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String? token = await _storage.read(key: "auth_token");
    if (token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://184.174.34.61:20001/api/voti'),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> voti = [];
        for (var item in data['voti']) {
          voti.add({
            "cognome": item["cognome"],
            "nome": item["nome"],
            "materia": item["materia"],
            "descr": item["descr"],
            "data": item["data"],
            "voto": item["voto"].toString(),
            "nomeCompleto": item["nomeCompleto"],
          });
        }

        setState(() {
          items = voti;
          isLoading = false;
        });
      } else {
        throw Exception('Errore nella richiesta: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Errore: $e';
        isLoading = false;
      });
    }
  }

  Color fromStringToColor(String s) {
    int hash = 0;
    if (s.isEmpty) return const Color.fromRGBO(0, 0, 0, 0);

    for (int i = 0; i < s.length; i++) {
      hash = s.codeUnitAt(i) + ((hash << 5) - hash);
      hash = hash & hash;
    }

    String color = "";
    for (int i = 0; i < 3; i++) {
      int value = (hash >> (i * 8)) & 255;
      color += value.toRadixString(16).padLeft(2, '0');
    }

    return Color(int.parse("FF$color", radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchItems,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('Nessun dato disponibile'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: fromStringToColor(items[index]['nomeCompleto']),
              child: Text(
                items[index]['materia'].toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            title: Text(
              items[index]['voto'].toString(),
              style: TextStyle(
                  color: fromStringToColor(items[index]['nomeCompleto']),
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(items[index]['descr'] ?? ''),
          ),
        );
      },
    );
  }
}



class AddVotoPage extends StatefulWidget {
  const AddVotoPage({super.key});

  @override
  State<AddVotoPage> createState() => _AddVotoPageState();
}

class _AddVotoPageState extends State<AddVotoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descrController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _selectedMateria;
  String? _selectedVoto;

  Future<bool> sendVoto(Map<String, dynamic> voto) async {
    String? token = await _storage.read(key: "auth_token");
    if (token == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return false;
    }
    try {

      final response = await http.post(
        Uri.parse('http://184.174.34.61:20001/api/voti'),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(voto),
      );

      if (response.statusCode == 200) {
        print("Voto inviato con successo!");
        return true;
      } else {
        print("Errore durante l'invio del voto: ${response.statusCode}");
        print("Risposta: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Errore nella richiesta POST: $e");
      return false;
    }
  }

  void _saveVoto() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riinsersci voti')),
        );
        return;
      }

      String votoSel = _selectedVoto!;

      double n = _selectedVoto == null ? 0 : double.parse(votoSel[0]);

      votoSel.contains('+') ? n += 0.25 : n;
      votoSel.contains('½') ? n += 0.5 : n;
      votoSel.contains('-') ? n -= 0.25 : n;

// Dati del voto
      final voto = {
        "idM": _selectedMateria,
        "descr": _descrController.text,
        "data": _dataController.text,
        "voto": n,
      };

      print("Voto salvato: $voto");
      try {
        bool result = await sendVoto(voto);

        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voto salvato con successo!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Errore durante il salvataggio del voto')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      } finally {
        _formKey.currentState!.reset();
        setState(() {
          _selectedMateria = null;
        });
        _descrController.clear();
        _dataController.clear();
        setState(() {
          _selectedVoto = null;
        });
      }
    } else {
      print("Errore non validato");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectMateria(
                  onSelected: (selectedMateria) {
                    setState(() {
                      _selectedMateria = selectedMateria;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descrController,
                  decoration: InputDecoration(
                    labelText: "Descrizione",
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Inserisci una descrizione",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor: Colors.purple.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade200, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade700, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red.shade300, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red.shade700, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(
                      Icons.description,
                      color: Colors.purple,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dataController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Data",
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Seleziona una data",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor: Colors.purple.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade200, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.purple.shade700, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red.shade300, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red.shade700, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.purple,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2040),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.purple,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.purple,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      _dataController.text = formattedDate;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Inserisci la data";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SelectVoto(
                  onSelected: (selectedVoto) {
                    setState(() {
                      _selectedVoto = selectedVoto!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveVoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("Salva Voto"),
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



class SelectMateria extends StatefulWidget {
  final Function(String?) onSelected;

  const SelectMateria({super.key, required this.onSelected});

  @override
  State<SelectMateria> createState() => _SelectMateria();
}

class _SelectMateria extends State<SelectMateria> {
  String? _selectedMateria;
  List<Map<String, dynamic>> _materie = [];
  bool _isLoadingMaterie = true;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchMaterie();
  }

  Future<void> _fetchMaterie() async {
    try {
      String? token = await _storage.read(key: "auth_token");
      if (token == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }
      final response = await http.get(
        Uri.parse('http://184.174.34.61:20001/api/materie'),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> mat = [];
        if (data.containsKey('materie')) {
          for (var item in data['materie']) {
            mat.add({
              "nome": item['nome'],
              "nomeCompleto": item['nomeCompleto'],
              "id": item['id'],
            });
          }
        }

        setState(() {
          _materie = mat;
          _isLoadingMaterie = false;
        });
      } else {
        throw Exception("Errore durante il caricamento delle materie");
      }
    } catch (e) {
      setState(() {
        _materie = [
          {'id': -1, "nome": 'ERR', "nomeCompleto": 'Errore load materie'}
        ];
        _isLoadingMaterie = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingMaterie
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : DropdownButtonFormField<String>(
            value: _selectedMateria,
            items: _materie.map((materia) {
              return DropdownMenuItem(
                value: materia['id'].toString(),
                child: Text(
                  materia['nomeCompleto'] as String,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMateria = value;
              });
              widget.onSelected(value);
            },
            decoration: InputDecoration(
              labelText: "Materia",
              labelStyle: const TextStyle(
                fontSize: 16,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
              hintText: "Seleziona Materia",
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: Colors.purple.shade50,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple.shade200, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.purple.shade700, width: 2.5),
                borderRadius: BorderRadius.circular(15),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade300, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade700, width: 2.5),
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(
                Icons.menu_book_sharp,
                color: Colors.purple,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Seleziona una materia";
              }
              return null;
            },
          );
  }
}



class SelectVoto extends StatefulWidget {
  final Function(String?) onSelected;

  const SelectVoto({super.key, required this.onSelected});

  @override
  State<SelectVoto> createState() => _SelectVoto();
}

class _SelectVoto extends State<SelectVoto> {
  String? _selectedVoto;
  final List<String> _votiInt = ['3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> _dec = ['-', '', '+', '½'];

  List<String> getVoti() {
    List<String> voti = [];
    for (var v in _votiInt) {
      for (var d in _dec) {
        voti.add(v + d);
      }
    }
    return voti;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> voti = getVoti();

    return DropdownButtonFormField<String>(
      value: _selectedVoto,
      items: voti.map((voto) {
        return DropdownMenuItem(
          value: voto,
          child: Text(voto),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedVoto = value;
        });
        widget.onSelected(value);
      },
      decoration: InputDecoration(
        labelText: "Voto",
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
        hintText: "Seleziona un voto",
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: Colors.purple.shade50,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple.shade200, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple.shade700, width: 2.5),
          borderRadius: BorderRadius.circular(15),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade700, width: 2.5),
          borderRadius: BorderRadius.circular(15),
        ),
        prefixIcon: const Icon(
          Icons.grading,
          color: Colors.purple,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Seleziona un voto";
        }
        return null;
      },
    );
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

//await _storage.write(key: "auth_token", value: '9d49670969b15d3bb62296fc25e3a8b1');

    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://184.174.34.61:20001/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'];

        await _storage.write(key: "auth_token", value: token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenziali errate!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di connessione: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Accedi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: "Inserisci il tuo username",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        filled: true,
                        fillColor: Colors.purple.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple.shade200, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple.shade700, width: 2.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.red.shade300, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red.shade700, width: 2.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.purple,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il tuo username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: "Inserisci password",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        filled: true,
                        fillColor: Colors.purple.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple.shade200, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple.shade700, width: 2.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.red.shade300, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red.shade700, width: 2.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.purple,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la tua password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _storage.delete(key: "auth_token");

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

