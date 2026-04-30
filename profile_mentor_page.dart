import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMentorPage extends StatefulWidget {
  final Map<String, dynamic> mentorData;
  const ProfileMentorPage({super.key, required this.mentorData});

  @override
  State<ProfileMentorPage> createState() => _ProfileMentorPageState();
}

class _ProfileMentorPageState extends State<ProfileMentorPage> {
  final PostService _postService = PostService();
  String? _currentPhotoBase64;

  @override
  void initState() {
    super.initState();
    _currentPhotoBase64 = widget.mentorData['photoUrl'];
  }

  // --- NOUVELLE FONCTION MISE À JOUR PHOTO PROFIL ---
  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (image != null) _processAndUploadImage(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une nouvelle photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                  if (image != null) _processAndUploadImage(image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processAndUploadImage(XFile image) async {
    final Uint8List bytes = await image.readAsBytes();
    final String base64Image = "data:image/png;base64,${base64.encode(bytes)}";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.mentorData['uid'])
        .update({'photoUrl': base64Image});

    if (mounted) {
      setState(() {
        _currentPhotoBase64 = base64Image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo de profil mise à jour !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isMyProfile = currentUser?.uid == widget.mentorData['uid'];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(widget.mentorData['name'] ?? "Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, isMyProfile)),
          if (isMyProfile)
            SliverToBoxAdapter(child: _buildCreatePostArea(context))
          else
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Publications & Compétences", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _postService.getMentorPosts(widget.mentorData['uid'] ?? ''), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: LinearProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("Aucune publication pour le moment."),
                    ),
                  ),
                );
              }
              final postsDocs = snapshot.data!.docs;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = postsDocs[index];
                    final postData = doc.data() as Map<String, dynamic>;
                    return _buildPostCard(context, postData, doc.id, isMyProfile);
                  },
                  childCount: postsDocs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMyProfile) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 15), 
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(height: 120, color: Colors.blue.shade100),
              Positioned(
                top: 60,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50, 
                        backgroundColor: Colors.blue.shade800, 
                        backgroundImage: (_currentPhotoBase64 != null) 
                            ? MemoryImage(base64Decode(_currentPhotoBase64!.split(',').last)) 
                            : null,
                        child: (_currentPhotoBase64 == null) 
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    if (isMyProfile)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _updateProfilePicture,
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 50),
          Text(widget.mentorData['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(widget.mentorData['email'] ?? '', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCreatePostArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, 
            backgroundImage: (_currentPhotoBase64 != null) 
                ? MemoryImage(base64Decode(_currentPhotoBase64!.split(',').last)) 
                : null,
            child: (_currentPhotoBase64 == null) ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _showPostDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: const Text("Partagez une compétence ou un projet..."),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post, String postId, bool canDelete) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18, 
                    backgroundImage: (_currentPhotoBase64 != null) 
                        ? MemoryImage(base64Decode(_currentPhotoBase64!.split(',').last)) 
                        : null,
                    child: (_currentPhotoBase64 == null) ? const Icon(Icons.person, size: 20) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.mentorData['name'] ?? 'Mentor', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDeletion(context, postId),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post['content'] ?? ''),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer"),
        content: const Text("Supprimer ce post ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              await _postService.deletePost(postId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Créer un post"),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _postService.createPost(
                  authorId: widget.mentorData['uid'],
                  content: controller.text.trim(),
                  skillTag: "Mentor", 
                );
                if (context.mounted) Navigator.pop(context);
              }
            }, 
            child: const Text("Publier")
          )
        ],
      ),
    );
  }
}