import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverUserID;
  final String name;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverUserID,
    required this.name,
  });

  TextEditingController messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    // Only send message if there is something to send
    if (messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverUserID, messageController.text);

      // Clear text controller after sending message
      messageController.clear();

      // Scroll to the bottom
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF38414F), Color(0xFF4A4E6A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Messages
            Expanded(child: _buildMessageList()),

            const SizedBox(
              height: 5,
            ),
            // User Input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var messages = snapshot.data!.docs;
        // Scroll to the bottom when new message is send
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index], context);
          },
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot document, BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Convert Firestore timestamp to DateTime
    DateTime dateTime = (data['timeStamp'] as Timestamp).toDate();

    // Format the timestamp
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    // Align the message to the right if the sender is current, otherwise left
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Messages view
    return Container(
      alignment: alignment,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Container(
          padding: const EdgeInsets.all(6),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70),
          decoration: BoxDecoration(
            borderRadius: isCurrentUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10))
                : const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
            color: Colors.black26,
          ),
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                data['message'],
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                formattedTime,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          )),
    );
  }

  // Build message input
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 17, color: Colors.white),
              controller: messageController,
              obscureText: false,
              decoration: const InputDecoration(
                hintText: 'Send Message',
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
            ),
          ),

          // Send Button
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              FontAwesomeIcons.share,
              size: 27,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
