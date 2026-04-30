import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              "Vous devez être connecté pour voir les demandes",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestion Mentorat"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: "En attente"),
              Tab(icon: Icon(Icons.history), text: "Historique"),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList(currentUser.uid, ['pending'], true),
            _buildRequestList(currentUser.uid, ['accepted', 'rejected'], false),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(
      String mentorId, List<String> statuses, bool showActions) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mentorships')
          .where('mentorId', isEqualTo: mentorId)
          // ✅ CORRIGÉ : suppression du .orderBy('createdAt') qui causait l'échec
          // silencieux de la requête (index composite manquant dans Firestore)
          // Le tri se fait maintenant en Dart ci-dessous
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                "Erreur de chargement: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                showActions ? "Aucune demande en attente" : "Aucun historique",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        // ✅ Filtre par statut en Dart (évite le besoin d'index Firestore)
        final allDocs = snapshot.data!.docs;
        final requests = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'pending';
          return statuses.contains(status);
        }).toList();

        // ✅ Tri par date en Dart
        requests.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final dateA = dataA['createdAt'];
          final dateB = dataB['createdAt'];
          if (dateA == null || dateB == null) return 0;
          return (dateB as dynamic).compareTo(dateA as dynamic);
        });

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                showActions ? "Aucune demande en attente" : "Aucun historique",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;

            // ✅ CORRIGÉ : cherche le nom dans plusieurs champs possibles
            final studentName = data['studentName'] as String? ??
                data['student_name'] as String? ??
                data['name'] as String? ??
                data['userName'] as String? ??
                "Étudiant inconnu";

            final status = data['status'] as String? ?? 'pending';
            final studentId = data['studentId'] as String?;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  radius: 28,
                  // ✅ BONUS : charge la photo de profil si disponible
                  child: studentId != null
                      ? FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(studentId)
                              .get(),
                          builder: (context, userSnap) {
                            if (userSnap.hasData && userSnap.data!.exists) {
                              final userData =
                                  userSnap.data!.data() as Map<String, dynamic>;
                              final photoUrl =
                                  userData['photoUrl'] as String? ??
                                      userData['profileImage'] as String? ??
                                      userData['avatar'] as String?;
                              if (photoUrl != null && photoUrl.isNotEmpty) {
                                return ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.blueAccent),
                                  ),
                                );
                              }
                            }
                            return const Icon(Icons.person,
                                color: Colors.blueAccent);
                          },
                        )
                      : const Icon(Icons.person, color: Colors.blueAccent),
                ),
                title: Text(
                  // ✅ CORRIGÉ : si le nom est toujours "Étudiant inconnu",
                  // on affiche l'ID tronqué pour déboguer
                  studentName != "Étudiant inconnu"
                      ? studentName
                      : (studentId != null
                          ? "Étudiant (${studentId.substring(0, 6)}...)"
                          : "Étudiant inconnu"),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    showActions
                        ? "Demande en attente"
                        : "Statut : ${_statusLabel(status)}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ),
                trailing: showActions
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green, size: 32),
                            tooltip: "Accepter",
                            onPressed: () => _updateStatus(
                                context, doc.id, 'accepted', studentName),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel,
                                color: Colors.redAccent, size: 32),
                            tooltip: "Refuser",
                            onPressed: () => _updateStatus(
                                context, doc.id, 'rejected', studentName),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'accepted'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: status == 'accepted'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status == 'accepted'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Refusé';
      case 'pending':
        return 'En attente';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _updateStatus(BuildContext context, String requestId,
      String newStatus, String studentName) async {
    try {
      await FirebaseFirestore.instance
          .collection('mentorships')
          .doc(requestId)
          .update({'status': newStatus});

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "$studentName → ${newStatus == 'accepted' ? 'Accepté ✅' : 'Refusé ❌'}"),
          backgroundColor:
              newStatus == 'accepted' ? Colors.green : Colors.redAccent,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}