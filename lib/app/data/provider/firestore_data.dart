import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/documents_model.dart';
import '../model/user_model.dart';

class FirestoreData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<DocumentModel?> getSecretKey(String iv) async {
    try {
      QuerySnapshot _doc = await _firestore
          .collection("files")
          .where("iv", isEqualTo: iv)
          .limit(1)
          .get(const GetOptions(
            source: Source.server,
          ));
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
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<DocumentModel>> getDocumentsListFromCache(
      String? ownerId, int limit,
      {DateTime? startAfter}) async {
    try {
      Query _query = _firestore
          .collection("files")
          .where("ownerId", isEqualTo: ownerId)
          .orderBy("createdOn", descending: true)
          .limit(limit);
      QuerySnapshot _docList;
      if (startAfter == null) {
        _docList = await _query.get(const GetOptions(source: Source.cache));
        // if (_docList.docs.isEmpty) {
        //   _docList = await _firestore
        //       .collection("files")
        //       .orderBy("createdOn", descending: true)
        //       .get(const GetOptions(source: Source.serverAndCache));
        // }
      } else {
        final Timestamp _startAfter = Timestamp.fromDate(startAfter);
        _docList = await _query.startAfter([_startAfter]).get(
            const GetOptions(source: Source.cache));
      }

      return _docList.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> _data = document.data()! as Map<String, dynamic>;
        return DocumentModel(
          ownerPhotoUrl: _data["ownerPhotoUrl"] as String?,
          ownerName: _data["ownerName"] as String?,
          secretKey: _data["secretKey"] as String?,
          iv: _data["iv"] as String?,
          documentName: _data["documentName"] as String?,
          documentSize: _data["documentSize"] as String?,
          ownerId: _data["ownerId"] as String?,
          createdOn: (_data["createdOn"] as Timestamp?)?.toDate(),
          documentId: document.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<DocumentModel?>> getDocumentsListFromServer(
    String? ownerId,
  ) async {
    try {
      QuerySnapshot _docList = await _firestore
          .collection("files")
          .where("ownerId", isEqualTo: ownerId)
          .orderBy("createdOn", descending: true)
          .limit(1)
          .get(const GetOptions(source: Source.server));

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
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentModel?> getDocument(String documentId) async {
    try {
      DocumentSnapshot _doc = await _firestore
          .collection("files")
          .doc(documentId)
          .get(const GetOptions(source: Source.server));

      Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

      return DocumentModel(
        ownerPhotoUrl: _data["ownerId"] as String,
        ownerName: _data["ownerName"] as String,
        secretKey: _data["secretKey"] as String,
        iv: _data["iv"] as String,
        documentName: _data["documentName"] as String,
        documentSize: _data["documentSize"] as String,
        ownerId: _data["ownerId"] as String,
        createdOn: (_data["createdOn"] as Timestamp).toDate(),
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

  static Future<void> createDocument(DocumentModel documentModel) async {
    try {
      await _firestore.collection("files").add(
        {
          "ownerId": documentModel.ownerId,
          "documentName": documentModel.documentName,
          "secretKey": documentModel.secretKey,
          "iv": documentModel.iv,
          "createdOn": FieldValue.serverTimestamp(),
          "documentSize": documentModel.documentSize,
          "ownerPhotoUrl": documentModel.ownerPhotoUrl,
          "ownerName": documentModel.ownerName,
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
  // Future<void> updatePhoneNumber(
  //     {required int phoneNumber, required String id}) async {
  //      try {
  //     await _firestore.collection("users").doc(id).update(
  //       {
  //         "phoneNumber": phoneNumber,
  //       },
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
