import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  String? _selectedChatId;
  String? _otherUserName;
  String? _otherUserId;

  @override
  Widget build(BuildContext context) {
    final String currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? "";

    if (currentUserId.isEmpty) {
      return const Scaffold(
          body: Center(child: Text("Veuillez vous connecter.")));
    }

    // ── Vue Chat privé ──────────────────────────────────────────────
    if (_selectedChatId != null) {
      return _ChatWindow(
        chatId: _selectedChatId!,
        otherName: _otherUserName!,
        otherUserId: _otherUserId!,
        currentUserId: currentUserId,
        onBack: () => setState(() {
          _selectedChatId = null;
          _otherUserName = null;
          _otherUserId = null;
        }),
      );
    }

    // ── Liste des conversations ─────────────────────────────────────
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text("Mes Discussions"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mentorships')
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Erreur : ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Filtre côté Dart — évite l'index composite Firestore
          final allDocs = snapshot.data?.docs ?? [];
          final docs = allDocs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return d['mentorId'] == currentUserId ||
                d['studentId'] == currentUserId;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 72, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucune discussion active",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Les conversations apparaissent après l'acceptation d'une demande de mentorat",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;
              final bool isMeMentor =
                  data['mentorId'] == currentUserId;

              // ✅ Nom de l'autre participant
              final String displayName = isMeMentor
                  ? (data['studentName'] as String? ?? "Étudiant")
                  : (data['mentorName'] as String? ?? "Mentor");

              final String otherId = isMeMentor
                  ? (data['studentId'] as String? ?? "")
                  : (data['mentorId'] as String? ?? "");

              // ✅ ID de chat unique et stable (trié alphabétiquement)
              final List<String> ids = [currentUserId, otherId]..sort();
              final String chatId = ids.join("_");

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Colors.blueAccent.withOpacity(0.12),
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: _LastMessagePreview(chatId: chatId),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
                onTap: () => setState(() {
                  _selectedChatId = chatId;
                  _otherUserName = displayName;
                  _otherUserId = otherId;
                }),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Aperçu du dernier message ──────────────────────────────────────────
class _LastMessagePreview extends StatelessWidget {
  final String chatId;
  const _LastMessagePreview({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Text("Cliquer pour discuter",
              style:
                  TextStyle(fontSize: 13, color: Colors.grey[500]));
        }
        final msg =
            snap.data!.docs.first.data() as Map<String, dynamic>;
        final type = msg['type'] as String? ?? 'text';
        final String preview;
        switch (type) {
          case 'audio':
            preview = "🎵 Message vocal";
            break;
          case 'image':
            preview = "📷 Photo";
            break;
          default:
            preview = msg['content'] as String? ?? "";
        }
        return Text(
          preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  FENÊTRE DE CHAT PRIVÉ
// ════════════════════════════════════════════════════════════════════════
class _ChatWindow extends StatefulWidget {
  final String chatId;
  final String otherName;
  final String otherUserId;
  final String currentUserId;
  final VoidCallback onBack;

  const _ChatWindow({
    required this.chatId,
    required this.otherName,
    required this.otherUserId,
    required this.currentUserId,
    required this.onBack,
  });

  @override
  State<_ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<_ChatWindow> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _hiddenMessages = {};

  // Audio — uniquement sur mobile (pas de dart:html)
  AudioRecorder? _audioRecorder;
  AudioPlayer? _audioPlayer;
  bool _isRecording = false;

  CollectionReference get _messagesRef => FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chatId)
      .collection('messages');

  @override
  void initState() {
    super.initState();
    // ✅ Initialise l'audio uniquement sur mobile
    if (!kIsWeb) {
      _audioRecorder = AudioRecorder();
      _audioPlayer = AudioPlayer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _audioRecorder?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  // ── Envoi texte ─────────────────────────────────────────────────
  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _messagesRef.add({
      'type': 'text',
      'content': text,
      'senderId': widget.currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _scrollToBottom();
  }

  // ── Envoi image ─────────────────────────────────────────────────
  // Sur web : galerie | Sur mobile : caméra
  Future<void> _sendPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
    );
    if (photo == null) return;

    try {
      final bytes = await photo.readAsBytes();
      final ref = fb_storage.FirebaseStorage.instance.ref().child(
            'chats/${widget.chatId}/images/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      await _messagesRef.add({
        'type': 'image',
        'content': url,
        'senderId': widget.currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur photo : $e")));
      }
    }
  }

  // ── Audio (mobile uniquement) ───────────────────────────────────
  Future<void> _startRecording() async {
    if (kIsWeb || _audioRecorder == null) return;
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder!.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (kIsWeb || _audioRecorder == null || !_isRecording) return;
    final path = await _audioRecorder!.stop();
    setState(() => _isRecording = false);
    if (path == null || !File(path).existsSync()) return;

    try {
      final ref = fb_storage.FirebaseStorage.instance.ref().child(
            'chats/${widget.chatId}/audio/${DateTime.now().millisecondsSinceEpoch}.m4a',
          );
      await ref.putFile(File(path));
      final url = await ref.getDownloadURL();

      await _messagesRef.add({
        'type': 'audio',
        'content': url,
        'senderId': widget.currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _scrollToBottom();
      await File(path).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur audio : $e")));
      }
    }
  }

  Future<void> _playAudio(String url) async {
    if (kIsWeb || _audioPlayer == null) return;
    try {
      await _audioPlayer!.setUrl(url);
      await _audioPlayer!.play();
    } catch (_) {}
  }

  // ── Suppression ─────────────────────────────────────────────────
  void _showOptions(String messageId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.orange),
            title: const Text("Supprimer pour moi"),
            onTap: () {
              setState(() => _hiddenMessages.add(messageId));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Supprimer pour tout le monde"),
            onTap: () async {
              await _messagesRef.doc(messageId).delete();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.otherName.isNotEmpty
                    ? widget.otherName[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.otherName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messagesRef
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Erreur : ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs
            .where((d) => !_hiddenMessages.contains(d.id))
            .toList();

        if (docs.isEmpty) {
          return Center(
            child: Text(
              "Démarrez la conversation avec\n${widget.otherName}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final isMe = data['senderId'] == widget.currentUserId;
            return GestureDetector(
              onLongPress: () => _showOptions(doc.id),
              child: _buildBubble(data, isMe),
            );
          },
        );
      },
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, bool isMe) {
    final type = msg['type'] ?? 'text';
    final content = msg['content'] ?? '';

    Widget body;
    if (type == 'audio') {
      body = GestureDetector(
        onTap: () => _playAudio(content),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill,
                color: isMe ? Colors.white70 : Colors.blueAccent,
                size: 26),
            const SizedBox(width: 8),
            Text("Message vocal",
                style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black87)),
          ],
        ),
      );
    } else if (type == 'image') {
      body = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(content,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 60)),
      );
    } else {
      body = Text(
        content,
        style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15),
      );
    }

    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: body,
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton photo
          IconButton(
            icon:
                const Icon(Icons.camera_alt, color: Colors.blueAccent),
            onPressed: _sendPhoto,
            tooltip: kIsWeb ? "Ajouter une image" : "Prendre une photo",
          ),

          // ✅ Bouton audio masqué sur web (pas de micro web sans dart:html)
          if (!kIsWeb)
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  color: _isRecording ? Colors.red : Colors.grey[600],
                  size: 26,
                ),
              ),
            ),

          // Champ texte
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: "Votre message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bouton envoyer
          GestureDetector(
            onTap: _sendText,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
