import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ImagePicker _imagePicker;

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ImagePicker? imagePicker,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _imagePicker = imagePicker ?? ImagePicker();

  Future<String?> pickAndEncodeProfileImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return null;
    }

    final bytes = await pickedFile.readAsBytes();

    return _compressAndEncode(bytes);
  }

  String _compressAndEncode(Uint8List bytes) {
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception('Unable to read the selected image.');
    }

    // Resize the image so Firestore doesn't have to store
    // a huge original phone/camera image.
    final resizedImage = img.copyResize(
      decodedImage,
      width: 300,
      height: 300,
      maintainAspect: true,
    );

    // JPEG quality 70 gives a good balance between
    // appearance and Firestore document size.
    final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

    return base64Encode(compressedBytes);
  }

  Future<void> updateProfileImage(String base64Image) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'profileImage': base64Image,
    }, SetOptions(merge: true));
  }

  Future<void> removeProfileImage() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'profileImage': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  Uint8List decodeBase64Image(String base64Image) {
    return base64Decode(base64Image);
  }
}
