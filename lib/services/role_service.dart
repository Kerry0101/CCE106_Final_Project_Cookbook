import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  static Stream<String> roleStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value('user');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((d) => (d.data()?['role'] ?? 'user') as String);
  }

  static Future<bool> isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return (snap.data()?['role'] ?? 'user') == 'admin';
  }

  static Future<String> getRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'user';
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return (snap.data()?['role'] ?? 'user') as String;
  }
}
