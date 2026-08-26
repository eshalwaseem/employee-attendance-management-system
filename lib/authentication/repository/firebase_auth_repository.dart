import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';

class FirebaseAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // ONE MANAGER FOR THE WHOLE COMPANY
  // ============================================================
  //
  // Replace this with the Firebase Authentication UID
  // of your manager.
  //
  static const String managerId = 'r5mh0r59tWZMMQVHpwa46znfBzp1';

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();

    try {
      // Create Firebase Authentication account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Unable to create your account.');
      }

      // Save name to Firebase Authentication
      await firebaseUser.updateDisplayName(normalizedName);

      // ========================================================
      // EVERY SIGNUP IS AN EMPLOYEE
      // EVERY EMPLOYEE GETS THE SAME MANAGER
      // ========================================================

      final user = User(
        id: firebaseUser.uid,
        name: normalizedName,
        email: normalizedEmail,

        // New accounts are ALWAYS employees
        role: UserRole.employee,

        // Automatically assign the one manager
        managerId: managerId,

        permissions: const [
          UserPermission.viewOwnAttendance,
          UserPermission.viewTeamAttendance,
        ],
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception('Unable to create your account.');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<User> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Unable to sign in.');
      }

      return await _getOrCreateFirestoreUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception('Unable to sign in.');
    }
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return _getOrCreateFirestoreUser(firebaseUser);
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // GET OR CREATE FIRESTORE USER
  // ============================================================

  Future<User> _getOrCreateFirestoreUser(
    firebase_auth.User firebaseUser,
  ) async {
    final reference = _firestore.collection('users').doc(firebaseUser.uid);

    final snapshot = await reference.get();

    // User already exists
    if (snapshot.exists && snapshot.data() != null) {
      return _userFromFirestore(firebaseUser, snapshot.data()!);
    }

    // ==========================================================
    // IF FIRESTORE PROFILE DOES NOT EXIST
    // CREATE IT AS AN EMPLOYEE
    // ==========================================================

    final user = User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      role: UserRole.employee,

      // Automatically assign the manager
      managerId: managerId,

      permissions: const [
        UserPermission.viewOwnAttendance,
        UserPermission.viewTeamAttendance,
      ],
    );

    await reference.set({
      ...user.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  // ============================================================
  // FIRESTORE → USER MODEL
  // ============================================================

  User _userFromFirestore(
    firebase_auth.User firebaseUser,
    Map<String, dynamic> data,
  ) {
    final permissions = <UserPermission>[];

    final permissionData = data['permissions'];

    if (permissionData is List) {
      for (final value in permissionData) {
        final permission = UserPermission.fromString(value.toString());

        if (permission != null) {
          permissions.add(permission);
        }
      }
    }

    return User(
      id: firebaseUser.uid,
      name: data['name'] as String? ?? firebaseUser.displayName ?? '',
      email: data['email'] as String? ?? firebaseUser.email ?? '',
      role: UserRole.fromString(data['role'] as String?),

      // Read managerId from Firestore
      managerId: data['managerId'] as String?,

      profileImagePath: data['profileImagePath'] as String?,

      permissions: permissions,
    );
  }

  // ============================================================
  // ASSIGN AUTHORITY
  // ============================================================
  //
  // Leave this here for future use.
  // We are NOT using an Employee Management screen right now.
  //

  Future<void> assignAuthority({
    required String employeeId,
    required UserRole role,
    required String? managerId,
    required List<UserPermission> permissions,
  }) async {
    await _firestore.collection('users').doc(employeeId).update({
      'role': role.value,
      'managerId': managerId,
      'permissions': permissions.map((permission) => permission.value).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // FIREBASE ERROR MESSAGES
  // ============================================================

  String _firebaseErrorMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account exists with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password must be at least 6 characters.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled in Firebase.';

      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
