import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> register(String email, String password, String name);
  Future<void> signOut();
}

class AuthRemoteDataSourceFirebaseImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final docMap = await _getUserDoc(user.uid);
    return _mapToEntity(user.uid, user.email ?? '', docMap);
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    if (cred.user == null) throw Exception("Failed to sign in");

    final docMap = await _getUserDoc(cred.user!.uid);
    return _mapToEntity(cred.user!.uid, email, docMap);
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null) throw Exception("Registration failed");

    // Save profile to firestore
    final docMap = {
      'name': name,
      'email': email,
      'role': 'Farmer',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(user.uid).set(docMap);
    
    return _mapToEntity(user.uid, email, docMap);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>?> _getUserDoc(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  UserEntity _mapToEntity(String uid, String email, Map<String, dynamic>? docMap) {
    return UserEntity(
      id: uid,
      email: email,
      name: docMap?['name'] as String? ?? 'User',
      role: docMap?['role'] as String? ?? 'Farmer',
      profileImageUrl: docMap?['profileImageUrl'] as String?,
    );
  }
}
