import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSentencePage extends StatefulWidget {
  const AddSentencePage({super.key});

  @override
  State<AddSentencePage> createState() => _AddSentencePageState();
}

class _AddSentencePageState extends State<AddSentencePage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _mntController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _meaningMntController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _exampleTranslateController =
      TextEditingController();

  List<String> _typeNames = [];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchTypeNames();
  }

  // Fetch Sentence Types from Firestore
  Future<void> _fetchTypeNames() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Sentence_Type').get();

      setState(() {
        _typeNames = snapshot.docs
            .map((doc) => doc['name'] as String)
            .toList();
        _selectedType = _typeNames.isNotEmpty ? _typeNames[0] : null; // Default to the first item if available
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // Save Sentence to Firestore
  Future<void> _saveSentence() async {
    if (_typeController.text.trim().isEmpty ||
        _wordController.text.trim().isEmpty ||
        _mntController.text.trim().isEmpty ||
        _meaningController.text.trim().isEmpty ||
        _meaningMntController.text.trim().isEmpty ||
        _exampleController.text.trim().isEmpty ||
        _exampleTranslateController.text.trim().isEmpty ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бүх талбарыг бөглөнө үү.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Saved_Sentences').add({
        'type': _typeController.text.trim(),
        'word': _wordController.text.trim(),
        'title': _selectedType,
        'mnt': _mntController.text.trim(),
        'meaning': _meaningController.text.trim(),
        'meaningMnt': _meaningMntController.text.trim(),
        'example': _exampleController.text.trim(),
        'exampleTranslate': _exampleTranslateController.text.trim(),
        // 'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Өгүүлбэр амжилттай хадгалагдлаа!')),
      );

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  void _clearFields() {
    _typeController.clear();
    _wordController.clear();
    _mntController.clear();
    _meaningController.clear();
    _meaningMntController.clear();
    _exampleController.clear();
    _exampleTranslateController.clear();
    setState(() {
      _selectedType = _typeNames.isNotEmpty ? _typeNames[0] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Өгүүлбэр хадгалах'),
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
                items: _typeNames.map<DropdownMenuItem<String>>((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Ямар төрлийнх вэ? Жш: interjection/ярианы хэллэг',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'Англи үг оруулна уу.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mntController,
                decoration: const InputDecoration(
                  labelText: 'Монгол орчуулга оруулна уу.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _meaningController,
                decoration: const InputDecoration(
                  labelText: 'Англи үгийн утгыг оруулна уу.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _meaningMntController,
                decoration: const InputDecoration(
                  labelText: 'Монгол үгийн утгыг оруулна уу.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exampleController,
                decoration: const InputDecoration(
                  labelText: 'Жишээ өгүүлбэр (Англи).',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exampleTranslateController,
                decoration: const InputDecoration(
                  labelText: 'Жишээ өгүүлбэр (Монгол).',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSentence,
                child: const Text('Өгүүлбэр Хадгалах'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}