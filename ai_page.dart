import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isRecording = false;
  bool _isLoading = false;

  late CollectionReference _messagesRef;

  static const String _supabaseFunctionUrl =
      'https://zgtxzbmhksidcjnqotbx.supabase.co/functions/v1/hf-chat';

  late stt.SpeechToText _speech;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initFirestore();
    _speech = stt.SpeechToText();
  }

  /// 🔥 Initialise Firestore
  void _initFirestore() {
    final uid = _auth.currentUser!.uid;

    _messagesRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc('default')
        .collection('messages');
  }

  /// 💾 Sauvegarde Firestore
  Future<void> _saveMessage(String role, String type, String data) async {
    await _messagesRef.add({
      "role": role,
      "type": type,
      "data": data,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isRecording = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _lastWords = val.recognizedWords;
        }),
      );
    }
  }

  void _stopListening() {
    setState(() => _isRecording = false);
    _speech.stop();
    if (_lastWords.isNotEmpty) {
      _sendToBackend(_lastWords);
      _lastWords = '';
    }
  }

  /// 🤖 Appel Supabase
  Future<void> _sendToBackend(String userText) async {
    setState(() => _isLoading = true);

    const supabaseAnonKey = "TON_ANON_KEY_ICI";

    try {
      await _saveMessage("user", "text", userText);

      final response = await http.post(
        Uri.parse(_supabaseFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $supabaseAnonKey',
          'apikey': supabaseAnonKey,
        },
        body: jsonEncode({"message": userText}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveMessage(
          "ai",
          "text",
          data["reply"] ?? "Réponse vide",
        );
      } else {
        throw Exception(data["reply"]);
      }
    } catch (e) {
      await _saveMessage("ai", "text", "❌ $e");
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _sendToBackend(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInput(),
        ],
      ),
    );
  }

  /// 📡 Stream Firestore
  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesRef
          .orderBy("createdAt")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final isUser = data["role"] == "user";

            return Align(
              alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data["data"],
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isRecording ? _stopListening : _startListening,
            child: CircleAvatar(
              backgroundColor:
                  _isRecording ? Colors.red : Colors.blue,
              child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendText(),
              decoration: const InputDecoration(
                hintText: "Écrire un message...",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendText,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }
}
