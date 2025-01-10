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
  List<String> _typeNames = []; // Type collection доторх name field-ийн жагсаалт
  String? _selectedType; // Dropdown-д сонгосон төрөл

  @override
  void initState() {
    super.initState();
    _fetchTypeNames(); // Firebase-ээс Type collection-ийн name field-ийг авах
  }

  // Firebase-аас Word collection-ийн name field-ийг авах
  Future<void> _fetchTypeNames() async {
    try {
      // Firestore collection-ийг асууна
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Word').get();

      setState(() {
        _typeNames = snapshot.docs
            .map((doc) => doc['name'] as String) // 'name' field-ийг авах
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // Save word to Firestore
  Future<void> _saveWord() async {
    if (_wordController.text.isEmpty ||
        _mongolianWordController.text.isEmpty ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бүх талбарыг бөглөнө үү.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Saved_Word').add({
        'englishWord': _wordController.text,
        'mongolianWord': _mongolianWordController.text,
        'type': _selectedType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Үг амжилттай хадгалагдлаа!')),
      );

      _wordController.clear();
      _mongolianWordController.clear();
      setState(() {
        _selectedType = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Үг нэмж хадгалах'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Dropdown for Type names
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
                  ? [DropdownMenuItem(value: null, child: Text('Төрөл сонгох'))]
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
                labelText: 'Үг оруулна уу - Англи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mongolianWordController,
              decoration: const InputDecoration(
                labelText: 'Үг оруулна уу - Монгол',
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
    );
  }
}
