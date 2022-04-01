import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filegram/app/data/model/views_model.dart';
import '../enums/docpermission.dart';
import 'package:flutter/services.dart';
import '../model/documents_model.dart';
import '../model/user_model.dart';

class FirestoreData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<DocumentModel?> getSecretKey(
    String iv,
    String? userEmail,
    String? ownerId,
  ) async {
    try {
      QuerySnapshot _doc = await _firestore
          .collection("files")
          .where("iv", isEqualTo: iv)
          .where("documentPermission",
              isEqualTo: DocumentPermission.public.name)
          .limit(1)
          .get();
      if (_doc.docs.isEmpty) {
        _doc = await _firestore
            .collection("files")
            .where("iv", isEqualTo: iv)
            .where("sharedEmailIds", arrayContains: userEmail)
            .limit(1)
            .get();
      }
      if (_doc.docs.isEmpty) {
        _doc = await _firestore
            .collection("files")
            .where("iv", isEqualTo: ownerId)
            .where("ownerId", arrayContains: userEmail)
            .limit(1)
            .get();
      }
      if (_doc.docs.isNotEmpty) {
        return DocumentModel(
          ownerPhotoUrl: _doc.docs.single["ownerPhotoUrl"] as String,
          ownerName: _doc.docs.single["ownerName"] as String,
          secretKey: _doc.docs.single["secretKey"] as String,
          iv: _doc.docs.single["iv"] as String,
          documentName: _doc.docs.single["documentName"] as String,
          documentSize: _doc.docs.single["documentSize"] as String,
          ownerId: _doc.docs.single["ownerId"] as String,
          createdOn: (_doc.docs.single["createdOn"] as Timestamp).toDate(),
          documentId: _doc.docs.single.id,
        );
      }
      return null;
    } on PlatformException {
      rethrow;
    }
  }

  static Future<List<DocumentModel>> getDocumentsListFromCache(
      String? ownerId, int limit,
      {DateTime? startAfter}) async {
    try {
      Query _query = _firestore
          .collection("files")
          .orderBy("createdOn", descending: true)
          .where("ownerId", isEqualTo: ownerId)
          .limit(limit);
      QuerySnapshot _docList;
      if (startAfter == null) {
        _docList = await _query.get(const GetOptions(source: Source.cache));
        if (_docList.docs.isEmpty) {
          _docList = await _firestore
              .collection("files")
              .orderBy("createdOn", descending: true)
              .where("ownerId", isEqualTo: ownerId)
              .get();
        }
      } else {
        final Timestamp _startAfter = Timestamp.fromDate(startAfter);
        _docList = await _query.startAfter([_startAfter]).get(
            const GetOptions(source: Source.cache));
      }

      return _docList.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> _data = document.data()! as Map<String, dynamic>;
        return DocumentModel(
          ownerPhotoUrl: _data["ownerPhotoUrl"] as String,
          ownerName: _data["ownerName"] as String,
          secretKey: _data["secretKey"] as String,
          iv: _data["iv"] as String,
          documentName: _data["documentName"] as String,
          documentSize: _data["documentSize"] as String,
          ownerId: _data["ownerId"] as String,
          createdOn: (_data["createdOn"] as Timestamp).toDate(),
          documentId: document.id,
          sharedEmailIds: List<String>.from(_data["sharedEmailIds"]),
          documentPermission:
              DocumentPermission.values.byName(_data["documentPermission"]),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentModel?> getDocument(
      DocumentReference _documentReference) async {
    try {
      DocumentSnapshot _doc = await _documentReference.get();

      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

      return DocumentModel(
        ownerPhotoUrl: _data["ownerPhotoUrl"] as String,
        ownerName: _data["ownerName"] as String,
        secretKey: _data["secretKey"] as String,
        iv: _data["iv"] as String,
        documentName: _data["documentName"] as String,
        documentSize: _data["documentSize"] as String,
        ownerId: _data["ownerId"] as String,
        createdOn: (_data["createdOn"] as Timestamp).toDate(),
        documentId: _doc.id,
        sharedEmailIds: List<String>.from(_data["sharedEmailIds"]),
        documentPermission:
            DocumentPermission.values.byName(_data["documentPermission"]),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentModel?> getDocumentAfterUpdate(String? uid) async {
    try {
      DocumentSnapshot _doc =
          await _firestore.collection("files").doc(uid).get();

      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

      return DocumentModel(
        ownerPhotoUrl: _data["ownerPhotoUrl"] as String,
        ownerName: _data["ownerName"] as String,
        secretKey: _data["secretKey"] as String,
        iv: _data["iv"] as String,
        documentName: _data["documentName"] as String,
        documentSize: _data["documentSize"] as String,
        ownerId: _data["ownerId"] as String,
        createdOn: (_data["createdOn"] as Timestamp).toDate(),
        documentId: _doc.id,
        sharedEmailIds: List<String>.from(_data["sharedEmailIds"]),
        documentPermission:
            DocumentPermission.values.byName(_data["documentPermission"]),
      );
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

  static Future<DocumentReference> createDocument(
      DocumentModel documentModel) async {
    try {
      return await _firestore.collection("files").add(
        {
          "ownerId": documentModel.ownerId,
          "documentName": documentModel.documentName,
          "secretKey": documentModel.secretKey,
          "iv": documentModel.iv,
          "createdOn": FieldValue.serverTimestamp(),
          "documentSize": documentModel.documentSize,
          "ownerPhotoUrl": documentModel.ownerPhotoUrl,
          "ownerName": documentModel.ownerName,
          "documentPermission": DocumentPermission.public.name,
          "sharedEmailIds": [documentModel.ownerEmailId],
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteDocument({
    String? documentId,
  }) async {
    try {
      await _firestore.collection("files").doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateDocumentPermission({
    String? documentId,
    List<String>? emailIds,
    required DocumentPermission documentPermission,
  }) async {
    try {
      await _firestore.collection("files").doc(documentId).update(
        {
          "documentPermission": documentPermission.name,
          "sharedEmailIds": emailIds,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createViewsAndUsers(String? documentId) async {
    try {
      await _firestore.collection("views").doc(documentId).set(
        {
          "views": 0,
          "users": 1,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteViewsAndUsers(String? documentId) async {
    try {
      await _firestore.collection("views").doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateViews(String? documentID) async {
    try {
      await _firestore.collection("views").doc(documentID).update(
        {
          "views": FieldValue.increment(1),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateViewsUsers(String? documentID) async {
    try {
      await _firestore.collection("views").doc(documentID).update(
        {
          "users": FieldValue.increment(1),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ViewsModel> readViewsAndUsers(String? documentID) async {
    try {
      DocumentSnapshot _doc =
          await _firestore.collection("views").doc(documentID).get();

      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
      return ViewsModel(
        views: _data["views"] as int?,
        numberOfUsers: _data["users"] as int?,
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
        id: _doc.id,
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
