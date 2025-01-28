import 'package:flutter/material.dart';
import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    const AddVotoPage(),
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
        childAspectRatio: 0.8, // Regola il rapporto altezza/larghezza
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final progressValue = (item['media'] ?? 0) / 10;
        final color = fromStringToColor(item["nomeCompleto"]);

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
                  height: 30,
                  width: 1,
                ),
                Text(
                  item["nome"],
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.black54,
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
    try {
      final response = await http.get(
        Uri.parse('http://184.174.34.61:20001/api/voti'),
        headers: {
          'Content-Type': 'application/json',
          'token': '9d49670969b15d3bb62296fc25e3a8b1'
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
              backgroundColor: fromStringToColor(items[index]['nomeCompleto']),
              child: Text(
                items[index]['materia'].toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              items[index]['voto'].toString(),
              style: TextStyle(
                  color: fromStringToColor(items[index]['nomeCompleto']),
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(items[index]['descr'].toString()),
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

  String? _selectedMateria;
  String? _selectedVoto;

Future<bool> sendVoto(Map<String, dynamic> voto) async {

  try {
    final response = await http.post(
      Uri.parse('http://184.174.34.61:20001/api/voti'),
      headers: {
        'Content-Type': 'application/json',
        'token': '9d49670969b15d3bb62296fc25e3a8b1',
      },
      body: jsonEncode(voto),
    );

    if (response.statusCode == 201) {
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
        
        if(_selectedVoto == null){
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
        "materia": _selectedMateria,
        "descrizione": _descrController.text,
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
                const SnackBar(content: Text('Errore durante il salvataggio del voto')),
            );
        }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: $e')),
        );
    }finally{
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
    }else{
        print("Errore non validato");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: AppBar(
      //     title: const Text("Aggiungi Voto"),
      //     backgroundColor: Colors.purple,
      //   ),
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
                TextFormField(
                  controller: _descrController,
                  decoration: const InputDecoration(labelText: "Descrizione"),
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _dataController,
                    readOnly: true, // Impedisce l'input manuale
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
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                            return Theme(
                            data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                primary: Colors.purple, // Colore principale
                                onPrimary: Colors.white, // Colore testo sul pulsante
                                onSurface: Colors.black, // Colore del testo nella lista
                                ),
                                textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.purple, // Colore dei pulsanti
                                ),
                                ),
                            ),
                            child: child!,
                            );
                        },
                        );

                        if (pickedDate != null) {
                        // Aggiorna il controller con la data selezionata
                        String formattedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
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

  @override
  void initState() {
    super.initState();
    _fetchMaterie();
  }

  Future<void> _fetchMaterie() async {
    try {
      final response = await http.get(
        Uri.parse('http://184.174.34.61:20001/api/materie'),
        headers: {
          'Content-Type': 'application/json',
          'token': '9d49670969b15d3bb62296fc25e3a8b1',
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
                value: materia['nome'] as String,
                child: Text(materia['nomeCompleto'] as String), 
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
                Icons.menu_book_sharp,
                color: Colors.purple,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
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


