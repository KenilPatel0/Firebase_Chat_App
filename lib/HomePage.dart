import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/ChatPage.dart'; // Ensure this is the correct path
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Auth_Service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final auth = FirebaseAuth.instance;
  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            authService.signOut();
          },
          icon: const Icon(Icons.exit_to_app),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF38414F), Color(0xFF4A4E6A)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (auth.currentUser!.email != data['email']) {
      return Container(
        margin: EdgeInsets.all(5),
        color: Colors.transparent,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 22,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          title: Text(
            '${data['name']}',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Get.to(() => ChatPage(
                  receiverEmail: data['email'],
                  receiverUserID: data['uid'],
                  name: data['name'],
                ));
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
