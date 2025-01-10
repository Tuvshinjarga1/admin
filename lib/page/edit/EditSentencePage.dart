import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSentencePage extends StatefulWidget {
  const EditSentencePage({super.key});

  @override
  State<EditSentencePage> createState() => _EditSentencePageState();
}

class _EditSentencePageState extends State<EditSentencePage> {
  List<String> _typeNames = []; // Sentence_Type дэх 'name' утгууд
  String? _selectedType; // Сонгогдсон төрөл
  List<DocumentSnapshot> _filteredSentences = []; // Шүүлтийн үр дүн

  @override
  void initState() {
    super.initState();
    _fetchTypeNames(); // Төрлийн жагсаалтыг татаж авна
  }

  // Төрлийн жагсаалтыг татах
  Future<void> _fetchTypeNames() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Sentence_Type').get();

      setState(() {
        _typeNames = snapshot.docs
            .map((doc) => doc['name'] as String) // 'name' талбарын утгуудыг авах
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // Сонгогдсон төрлөөр өгүүлбэрүүдийг шүүх
  Future<void> _fetchSentencesByType(String type) async {
    try {
      final QuerySnapshot sentencesSnapshot = await FirebaseFirestore.instance
          .collection('Saved_Sentences')
          .where('type', isEqualTo: type)
          .get();

      setState(() {
        _filteredSentences = sentencesSnapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  // Өгүүлбэрийг засварлах
  void _editSentence(DocumentSnapshot sentenceDoc) {
    final TextEditingController controller = TextEditingController(
      text: sentenceDoc['sentence'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Өгүүлбэр засах'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Өгүүлбэр'),
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
                await sentenceDoc.reference.update({'sentence': controller.text.trim()});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Өгүүлбэр амжилттай шинэчлэгдлээ!')),
                );
                _fetchSentencesByType(_selectedType!); // Шүүлтийг шинэчлэх
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
        title: const Text('Өгүүлбэр засах'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Төрлөө сонгоно уу:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedType,
              hint: const Text('Төрөл сонгох'),
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
                if (newValue != null) {
                  _fetchSentencesByType(newValue); // Сонгосон төрлөөр шүүх
                }
              },
              items: _typeNames.map<DropdownMenuItem<String>>((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSentences.length,
                itemBuilder: (context, index) {
                  final sentenceDoc = _filteredSentences[index];
                  return ListTile(
                    title: Text(sentenceDoc['sentence']),
                    subtitle: Text('Төрөл: ${sentenceDoc['type']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editSentence(sentenceDoc),
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
