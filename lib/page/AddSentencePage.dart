import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSentencePage extends StatefulWidget {
  const AddSentencePage({super.key});

  @override
  State<AddSentencePage> createState() => _AddSentencePageState();
}

class _AddSentencePageState extends State<AddSentencePage> {
  final TextEditingController _sentenceController = TextEditingController();
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
    if (_sentenceController.text.trim().isEmpty || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Өгүүлбэр болон төрлийг сонгоно уу.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Saved_Sentences').add({
        'sentence': _sentenceController.text.trim(),
        'type': _selectedType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Урьдач өгүүлбэр амжилттай хадгалагдлаа!')),
      );

      _sentenceController.clear();
      setState(() {
        _selectedType = _typeNames.isNotEmpty ? _typeNames[0] : null; // Reset to the first item
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
        title: const Text('Өгүүлбэр хадгалах'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              controller: _sentenceController,
              decoration: const InputDecoration(
                labelText: 'Өгүүлбэр оруулна уу.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveSentence,
              child: const Text('Өгүүлбэр Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }
}
