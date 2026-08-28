import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';

class FirebaseAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String managerId = 'r5mh0r59tWZMMQVHpwa46znfBzp1';


  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final normalizedName = name.trim();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Unable to create your account.');
      }

      await firebaseUser.updateDisplayName(normalizedName);

      final createdAt = DateTime.now();

      final user = User(
        id: firebaseUser.uid,
        name: normalizedName,
        email: normalizedEmail,
        role: UserRole.employee,
        managerId: managerId,
        permissions: const [
          UserPermission.viewOwnAttendance,
          UserPermission.viewTeamAttendance,
        ],
        createdAt: createdAt,
      );

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


  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return _getOrCreateFirestoreUser(firebaseUser);
  }


  Future<void> logout() async {
    await _auth.signOut();
  }


  Future<User> updateName({required String name}) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No authenticated user found.');
    }

    final normalizedName = name.trim();

    if (normalizedName.length < 2) {
      throw Exception('Name must be at least 2 characters.');
    }

    await firebaseUser.updateDisplayName(normalizedName);

    final userReference = _firestore.collection('users').doc(firebaseUser.uid);

    await userReference.update({
      'name': normalizedName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await userReference.get();

    if (snapshot.exists && snapshot.data() != null) {
      return _userFromFirestore(firebaseUser, snapshot.data()!);
    }

    throw Exception('Unable to load updated user information.');
  }


  Future<User> updateProfileImage({required String imageUrl}) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No authenticated user found.');
    }

    if (imageUrl.trim().isEmpty) {
      throw Exception('Profile image URL cannot be empty.');
    }

    final userReference = _firestore.collection('users').doc(firebaseUser.uid);

    await userReference.set({
      'profileImagePath': imageUrl.trim(),

      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final snapshot = await userReference.get();

    if (snapshot.exists && snapshot.data() != null) {
      return _userFromFirestore(firebaseUser, snapshot.data()!);
    }

    throw Exception('Unable to save profile image.');
  }


  Future<User> removeProfileImage() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No authenticated user found.');
    }

    final userReference = _firestore.collection('users').doc(firebaseUser.uid);

    await userReference.set({
      'profileImagePath': FieldValue.delete(),

      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final snapshot = await userReference.get();

    if (snapshot.exists && snapshot.data() != null) {
      return _userFromFirestore(firebaseUser, snapshot.data()!);
    }

    throw Exception('Unable to remove profile image.');
  }


  Future<User> _getOrCreateFirestoreUser(
    firebase_auth.User firebaseUser,
  ) async {
    final reference = _firestore.collection('users').doc(firebaseUser.uid);

    final snapshot = await reference.get();


    if (snapshot.exists && snapshot.data() != null) {
      return _userFromFirestore(firebaseUser, snapshot.data()!);
    }

    final createdAt = DateTime.now();

    final user = User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      role: UserRole.employee,
      managerId: managerId,
      permissions: const [
        UserPermission.viewOwnAttendance,
        UserPermission.viewTeamAttendance,
      ],
      createdAt: createdAt,
    );

    await reference.set({
      ...user.toJson(),

      'createdAt': FieldValue.serverTimestamp(),

      'updatedAt': FieldValue.serverTimestamp(),
    });

    return user;
  }


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

      managerId: data['managerId'] as String?,

      profileImagePath: data['profileImagePath'] as String?,

      permissions: permissions,

      createdAt: _parseCreatedAt(data['createdAt'], firebaseUser),
    );
  }


  DateTime _parseCreatedAt(dynamic value, firebase_auth.User firebaseUser) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    final firebaseCreationTime = firebaseUser.metadata.creationTime;

    if (firebaseCreationTime != null) {
      return firebaseCreationTime;
    }

    return DateTime(2000);
  }


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
