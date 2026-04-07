import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded admin credentials
  static const String adminEmail = 'admin@laza.com';
  static const String adminPassword = 'admin123';
  static const String adminName = 'Admin User';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthState();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.id, doc.data()!);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Check if trying to create admin account
      final isAdmin = email.toLowerCase() == adminEmail.toLowerCase();

      // For admin, allow signup without Firebase if needed
      if (isAdmin && email == adminEmail && password == adminPassword) {
        _currentUser = UserModel(
          id: 'admin_001',
          name: adminName,
          email: adminEmail,
          address: '',
          city: '',
          zipCode: '',
          isAdmin: true,
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Create user document in Firestore
      final newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        address: '',
        city: '',
        zipCode: '',
        isAdmin: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(newUser.toMap());
      _currentUser = newUser;

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // If Firebase fails but it's admin, still allow
      if (email.toLowerCase() == adminEmail.toLowerCase() &&
          password == adminPassword) {
        _currentUser = UserModel(
          id: 'admin_001',
          name: adminName,
          email: adminEmail,
          address: '',
          city: '',
          zipCode: '',
          isAdmin: true,
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }
      _errorMessage = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    // Check for hardcoded admin first
    if (email.toLowerCase() == adminEmail.toLowerCase() &&
        password == adminPassword) {
      _currentUser = UserModel(
        id: 'admin_001',
        name: adminName,
        email: adminEmail,
        address: '123 Admin Street',
        city: 'Manila',
        zipCode: '1000',
        isAdmin: true,
        createdAt: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
      return true;
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserFromFirestore(userCredential.user!.uid);
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    // Admin password reset
    if (email.toLowerCase() == adminEmail.toLowerCase()) {
      _setLoading(false);
      return true;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? address,
    String? city,
    String? zipCode,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);

    try {
      // For hardcoded admin, just update local
      if (_currentUser!.id == 'admin_001') {
        _currentUser = _currentUser!.copyWith(
          name: name,
          address: address,
          city: city,
          zipCode: zipCode,
        );
        _setLoading(false);
        notifyListeners();
        return;
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (address != null) updates['address'] = address;
      if (city != null) updates['city'] = city;
      if (zipCode != null) updates['zipCode'] = zipCode;

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updates);

      _currentUser = _currentUser!.copyWith(
        name: name,
        address: address,
        city: city,
        zipCode: zipCode,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> updateAddress(
    String address,
    String city,
    String zipCode,
  ) async {
    await updateProfile(address: address, city: city, zipCode: zipCode);
  }

  Future<void> logout() async {
    // For hardcoded admin, just clear local
    if (_currentUser?.id == 'admin_001') {
      _currentUser = null;
      notifyListeners();
      return;
    }

    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
