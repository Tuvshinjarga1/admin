import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _mongolianWordController = TextEditingController();
  final TextEditingController _pronounceController = TextEditingController();
  final TextEditingController _exampleEnController = TextEditingController();
  final TextEditingController _exampleMnController = TextEditingController();

  List<String> _typeNames = []; // Төрөл жагсаалт
  String? _selectedType; // Сонгосон төрөл

  @override
  void initState() {
    super.initState();
    _fetchTypeNames(); // Firebase-ээс төрлийн нэрсийг авах
  }

  // Firebase-аас төрөл нэрсийг авах
  Future<void> _fetchTypeNames() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Word').get();
      setState(() {
        _typeNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // Firebase-д үг хадгалах
  Future<void> _saveWord() async {
    if (_wordController.text.isEmpty ||
        _mongolianWordController.text.isEmpty ||
        _pronounceController.text.isEmpty ||
        _exampleEnController.text.isEmpty ||
        _exampleMnController.text.isEmpty ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бүх талбарыг бөглөнө үү.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Saved_Word').add({
        'word': _wordController.text, // Англи үг
        'pronounce': _pronounceController.text, // Дуудлага
        'mnt': _mongolianWordController.text, // Монгол орчуулга
        'type': _selectedType, // Төрөл
        'exampleEn': _exampleEnController.text, // Англи өгүүлбэр
        'exampleMn': _exampleMnController.text, // Монгол өгүүлбэр
        // 'createdAt': FieldValue.serverTimestamp(), // Огноо
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Үг амжилттай хадгалагдлаа!')),
      );

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  void _clearFields() {
    _wordController.clear();
    _mongolianWordController.clear();
    _pronounceController.clear();
    _exampleEnController.clear();
    _exampleMnController.clear();
    setState(() {
      _selectedType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Үг нэмэх'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Төрөл сонгох:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                items: _typeNames.isEmpty
                    ? [const DropdownMenuItem(value: null, child: Text('Төрөл сонгох'))]
                    : _typeNames.map<DropdownMenuItem<String>>((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'Англи үг оруулна уу',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mongolianWordController,
                decoration: const InputDecoration(
                  labelText: 'Монгол орчуулга оруулна уу',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pronounceController,
                decoration: const InputDecoration(
                  labelText: 'Дуудлага (жишээ: тийчэр)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exampleEnController,
                decoration: const InputDecoration(
                  labelText: 'Жишээ өгүүлбэр (Англи)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exampleMnController,
                decoration: const InputDecoration(
                  labelText: 'Жишээ өгүүлбэр (Монгол)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveWord,
                child: const Text('Хадгалах'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
