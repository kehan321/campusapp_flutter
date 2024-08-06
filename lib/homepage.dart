// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Listings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('jobs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final jobs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return ListTile(
                title: Text(job['title']),
                subtitle: Text(job['description']),
                trailing: ElevatedButton(
                  onPressed: () {
                    _firestore
                        .collection('applications')
                        .add({
                          'jobId': job.id,
                          'userId': FirebaseAuth.instance.currentUser!.uid,
                          'status': 'applied',
                        })
                        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Applied successfully!'),
                            )))
                        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to apply: $error'),
                            )));
                  },
                  child: Text('Apply'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
