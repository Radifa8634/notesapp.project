import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatefulWidget {
  final String? docId;
  final String? existingTitle;
  final String? existingDesc;

  const NotesScreen({super.key, this.docId, this.existingTitle, this.existingDesc});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    title.text = widget.existingTitle ?? '';
    desc.text = widget.existingDesc ?? '';
  }

  Future<void> saveNote() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    try {
      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('notes').add({
          'title': title.text.trim(),
          'desc': desc.text.trim(),
          'uid': uid,
          'time': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
        );
      } else {
        await FirebaseFirestore.instance.collection('notes').doc(widget.docId).update({
          'title': title.text.trim(),
          'desc': desc.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated successfully')),
        );
      }

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, '/allNotes');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: desc,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveNote,
              child: Text(isEditing ? 'Update Note' : 'Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}
