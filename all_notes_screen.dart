import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notes_screen.dart';

class AllNotesScreen extends StatelessWidget {
  const AllNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final CollectionReference notesCollection =
    FirebaseFirestore.instance.collection('notes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notes'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: notesCollection
            .where('uid', isEqualTo: uid)
        // 🔴 TEMPORARILY COMMENT THIS LINE if index not created
        // .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final noteId = note.id;
              final title = note['title'] ?? 'Untitled';
              final desc = note['desc'] ?? '';

              return ListTile(
                title: Text(title),
                subtitle: Text(desc),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotesScreen(
                              docId: noteId,
                              existingTitle: title,
                              existingDesc: desc,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await notesCollection.doc(noteId).delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note deleted')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addNote');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
