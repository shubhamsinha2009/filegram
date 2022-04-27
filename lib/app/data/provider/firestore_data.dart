import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filegram/app/data/model/views_model.dart';
import '../enums/docpermission.dart';
import 'package:flutter/services.dart';
import '../model/documents_model.dart';
import '../model/gullak_model.dart';
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
        Map<String, dynamic> _data =
            _doc.docs.single.data()! as Map<String, dynamic>;

        return DocumentModel(
          ownerPhotoUrl: _data["ownerPhotoUrl"] as String,
          ownerName: _data["ownerName"] as String,
          secretKey: _data["secretKey"] as String,
          iv: _data["iv"] as String,
          documentName: _data["documentName"] as String,
          documentSize: _data["documentSize"] as String,
          ownerId: _data["ownerId"] as String,
          createdOn: (_data["createdOn"] as Timestamp).toDate(),
          documentId: _doc.docs.single.id,
          sourceUrl: _data.containsKey("sourceUrl") ? _data["sourceUrl"] : null,
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
          sourceUrl: _data.containsKey("sourceUrl") ? _data["sourceUrl"] : null,
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
        sourceUrl: _data.containsKey("sourceUrl") ? _data["sourceUrl"] : null,
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
        sourceUrl: _data.containsKey("sourceUrl") ? _data["sourceUrl"] : null,
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

  static Future<void> updatePhoneUser(
      {required String id, required String phoneNumber}) async {
    try {
      await _firestore.collection("users").doc(id).update({
        "phoneNumber": phoneNumber,
      });
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
          "sourceUrl": documentModel.sourceUrl,
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

  static Future<void> setSourceUrl({
    required String? documentId,
    required String? sourceUrl,
  }) async {
    try {
      await _firestore.collection("files").doc(documentId).set({
        "sourceUrl": sourceUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createViewsAndUploads(String? documentId) async {
    try {
      await _firestore.collection("views").doc(documentId).set(
        {
          "views": 0,
          "uploads": 1,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteViewsAndUploads(String? documentId) async {
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

  static Future<void> updateUploads(String? documentID) async {
    try {
      await _firestore.collection("views").doc(documentID).update(
        {
          "uploads": FieldValue.increment(1),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ViewsModel> readViewsAndUploads(String? documentID) async {
    try {
      DocumentSnapshot _doc =
          await _firestore.collection("views").doc(documentID).get();

      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
      return ViewsModel(
        views: _data["views"] as int?,
        numberOfUploads: _data["uploads"] as int?,
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

  static Future<void> createGullak(String? userId) async {
    try {
      await _firestore.collection("gullak").doc(userId).set(
        {
          "sikka": 0,
          "withdrawalLink": "",
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<GullakModel> getGullak(String uid) {
    try {
      Stream<DocumentSnapshot> _snapshot =
          _firestore.collection("gullak").doc(uid).snapshots();

      return _snapshot.map((_doc) {
        if (!_doc.exists) {
          createGullak(uid).then((value) => _firestore
              .collection("gullak")
              .doc(uid)
              .snapshots()
              .map((event) => _doc = event));
        }
        Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
        return GullakModel(
          sikka: _data["sikka"],
          withdrawalLink: _data.containsKey("withdrawalLink")
              ? _data["withdrawalLink"]
              : "",
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateSikka(String uid) async {
    try {
      await _firestore.collection("gullak").doc(uid).update(
        {
          "sikka": FieldValue.increment(1),
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
