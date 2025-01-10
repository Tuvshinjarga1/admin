import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditWordPage extends StatefulWidget {
  const EditWordPage({super.key});

  @override
  State<EditWordPage> createState() => _EditWordPageState();
}

class _EditWordPageState extends State<EditWordPage> {
  List<String> _wordNames = []; // Word collection-ийн нэрс
  String? _selectedWord; // Сонгогдсон үг
  List<DocumentSnapshot> _filteredWords = []; // Сонгогдсон үгтэй ижил үгнүүд

  @override
  void initState() {
    super.initState();
    _fetchWordNames(); // Үгийн нэрсийг татах
  }

  // Word collection-ийн нэрсийг татах
  Future<void> _fetchWordNames() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Word').get();

      setState(() {
        _wordNames = snapshot.docs
            .map((doc) => doc['name'] as String) // 'name' талбарын утгуудыг авах
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // Сонгогдсон үгээр шүүлт хийх
  Future<void> _fetchWordsBySelectedName(String name) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Saved_Word')
          .where('type', isEqualTo: name) // `type` талбар нь `name`-тэй тэнцэх
          .get();

      setState(() {
        _filteredWords = snapshot.docs; // Шүүгдсэн үгс
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // 'Saved_Word' collection-ийн бүх талбарыг засах
  void _editSavedWord(DocumentSnapshot wordDoc) {
    final TextEditingController exampleEnController = TextEditingController(
      text: wordDoc['exampleEn'], // 'exampleEn' талбарын утгыг авах
    );
    final TextEditingController exampleMnController = TextEditingController(
      text: wordDoc['exampleMn'], // 'exampleMn' талбарын утгыг авах
    );
    final TextEditingController mntController = TextEditingController(
      text: wordDoc['mnt'], // 'mnt' талбарын утгыг авах
    );
    final TextEditingController pronounceController = TextEditingController(
      text: wordDoc['pronounce'], // 'pronounce' талбарын утгыг авах
    );
    final TextEditingController typeController = TextEditingController(
      text: wordDoc['type'], // 'type' талбарын утгыг авах
    );
    final TextEditingController wordController = TextEditingController(
      text: wordDoc['word'], // 'word' талбарын утгыг авах
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Үг засах'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: mntController,
                decoration: const InputDecoration(labelText: 'MNT'),
              ),
              TextField(
                controller: wordController,
                decoration: const InputDecoration(labelText: 'Word'),
              ),
              TextField(
                controller: pronounceController,
                decoration: const InputDecoration(labelText: 'Pronounce'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: exampleEnController,
                decoration: const InputDecoration(labelText: 'Example in English'),
              ),
              TextField(
                controller: exampleMnController,
                decoration: const InputDecoration(labelText: 'Example in Mongolian'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Болих'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await wordDoc.reference.update({
                  'exampleEn': exampleEnController.text.trim(),
                  'exampleMn': exampleMnController.text.trim(),
                  'mnt': mntController.text.trim(), // 'mnt' => 'mongolianWord'
                  'pronounce': pronounceController.text.trim(),
                  'type': typeController.text.trim(),
                  'word': wordController.text.trim(), // 'word' => 'englishWord'
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Үг амжилттай шинэчлэгдлээ!')),
                );
                _fetchWordsBySelectedName(_selectedWord!); // Шүүлтийг шинэчлэх
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Алдаа гарлаа: $e')),
                );
              }
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Үг засах'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Үг сонгоно уу:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedWord,
              hint: const Text('Үг сонгох'),
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWord = newValue;
                });
                if (newValue != null) {
                  _fetchWordsBySelectedName(newValue); // Сонгосон үгээр шүүлт хийх
                }
              },
              items: _wordNames.map<DropdownMenuItem<String>>((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredWords.length,
                itemBuilder: (context, index) {
                  final wordDoc = _filteredWords[index];
                  return ListTile(
                    // title: Text(wordDoc['type']), // 'type' талбарын утга
                    subtitle: Text(
                      'English: ${wordDoc['word']} \nMongolian: ${wordDoc['mnt']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editSavedWord(wordDoc), // Үгийг засах
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}