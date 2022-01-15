import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filegram/app/data/model/documents_model.dart';
import 'package:filegram/app/data/model/user_model.dart';

class FirestoreData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<DocumentModel?> getSecretKey(String iv) async {
    try {
      QuerySnapshot _doc = await _firestore
          .collection("files")
          .where("iv", isEqualTo: iv)
          .limit(1)
          .get();
      if (_doc.docs.isNotEmpty) {
        return DocumentModel(
          ownerPhotoUrl: _doc.docs.single["ownerPhotoUrl"],
          ownerName: _doc.docs.single["ownerName"],
          secretKey: await _doc.docs.single["secretKey"],
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createNewUser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.id).set(
        {
          "emailId": user.emailId,
          "photoUrl": user.photoUrl,
          "name": user.name,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createDocument(DocumentModel documentModel) async {
    try {
      await _firestore.collection("files").add(
        {
          "ownerId": documentModel.ownerId,
          "documentName": documentModel.documentName,
          "secretKey": documentModel.secretKey,
          "iv": documentModel.iv,
          "createdOn": FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteUser(String? uid) async {
    try {
      await _firestore.collection("contentCreators").doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePhoneNumber(
      {required int phoneNumber, required String id}) async {
    try {
      await _firestore.collection("users").doc(id).update(
        {
          "phoneNumber": phoneNumber,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> userNotExists(String? uid) async {
    try {
      DocumentSnapshot _doc =
          await _firestore.collection("users").doc(uid).get();
      return _doc.exists ? false : true;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot _doc = await _firestore
          .collection("users")
          .doc(uid)
          .get(const GetOptions(source: Source.cache));
      if (!_doc.exists) {
        _doc = await _firestore
            .collection("users")
            .doc(uid)
            .get(const GetOptions(source: Source.serverAndCache));
      }
      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

      return UserModel(
        emailId: _data["emailId"] as String,
        photoUrl: _data["photoUrl"] as String,
        name: _data["name"] as String,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserFromServer(String uid) async {
    try {
      DocumentSnapshot _doc = await _firestore
          .collection("users")
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));

      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

      return UserModel(
        emailId: _data["emailId"] as String,
        photoUrl: _data["photoUrl"] as String,
        name: _data["name"] as String,
      );
    } catch (e) {
      rethrow;
    }
  }
}
