import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filegram/app/data/model/views_model.dart';
import '../enums/docpermission.dart';
import 'package:flutter/services.dart';

import '../model/documents_model.dart';
import '../model/gullak_model.dart';

import '../model/user_model.dart';

class FirestoreData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<DocumentModel?> getSecretKey({
    required String iv,
    String? userEmail,
    String? ownerId,
    required String collection,
  }) async {
    try {
      QuerySnapshot doc = await _firestore
          .collection(collection)
          .where("iv", isEqualTo: iv)
          .where("documentPermission",
              isEqualTo: DocumentPermission.public.name)
          .limit(1)
          .get();
      if (doc.docs.isEmpty) {
        doc = await _firestore
            .collection("files")
            .where("iv", isEqualTo: iv)
            .where("sharedEmailIds", arrayContains: userEmail)
            .limit(1)
            .get();
      }
      if (doc.docs.isEmpty) {
        doc = await _firestore
            .collection("files")
            .where("iv", isEqualTo: ownerId)
            .where("ownerId", arrayContains: userEmail)
            .limit(1)
            .get();
      }
      if (doc.docs.isNotEmpty) {
        Map<String, dynamic> data =
            doc.docs.single.data()! as Map<String, dynamic>;

        return DocumentModel(
          ownerPhotoUrl: data["ownerPhotoUrl"] as String,
          ownerName: data["ownerName"] as String,
          secretKey: data["secretKey"] as String,
          iv: data["iv"] as String,
          documentName: data["documentName"] as String,
          documentSize: data["documentSize"] as String,
          ownerId: data["ownerId"] as String,
          createdOn: (data["createdOn"] as Timestamp).toDate(),
          documentId: doc.docs.single.id,
          sourceUrl: data.containsKey("sourceUrl") ? data["sourceUrl"] : null,
        );
      }
      return null;
    } on PlatformException {
      rethrow;
    }
  }

  static Future<List<DocumentModel>> getDocumentsListFromCache({
    String? ownerId,
    required String collection,
  }) async {
    try {
      Query query = _firestore
          .collection(collection)
          .orderBy("createdOn", descending: true)
          .where("ownerId", isEqualTo: ownerId);
      QuerySnapshot docList;

      docList = await query.get(const GetOptions(source: Source.cache));
      if (docList.docs.isEmpty) {
        docList = await _firestore
            .collection("files")
            .orderBy("createdOn", descending: true)
            .where("ownerId", isEqualTo: ownerId)
            .get();
      }

      return docList.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        return DocumentModel(
          ownerPhotoUrl: data["ownerPhotoUrl"] as String,
          ownerName: data["ownerName"] as String,
          secretKey: data["secretKey"] as String,
          iv: data["iv"] as String,
          documentName: data["documentName"] as String,
          documentSize: data["documentSize"] as String,
          ownerId: data["ownerId"] as String,
          createdOn: (data["createdOn"] as Timestamp).toDate(),
          documentId: document.id,
          sharedEmailIds: List<String>.from(data["sharedEmailIds"]),
          documentPermission:
              DocumentPermission.values.byName(data["documentPermission"]),
          sourceUrl: data.containsKey("sourceUrl") ? data["sourceUrl"] : null,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentModel?> getDocument(
      DocumentReference documentReference) async {
    try {
      DocumentSnapshot doc = await documentReference.get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return DocumentModel(
        ownerPhotoUrl: data["ownerPhotoUrl"] as String,
        ownerName: data["ownerName"] as String,
        secretKey: data["secretKey"] as String,
        iv: data["iv"] as String,
        documentName: data["documentName"] as String,
        documentSize: data["documentSize"] as String,
        ownerId: data["ownerId"] as String,
        createdOn: (data["createdOn"] as Timestamp).toDate(),
        documentId: doc.id,
        sharedEmailIds: List<String>.from(data["sharedEmailIds"]),
        documentPermission:
            DocumentPermission.values.byName(data["documentPermission"]),
        sourceUrl: data.containsKey("sourceUrl") ? data["sourceUrl"] : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<DocumentModel?> getDocumentAfterUpdate({
    String? uid,
    required String collection,
  }) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collection).doc(uid).get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return DocumentModel(
        ownerPhotoUrl: data["ownerPhotoUrl"] as String,
        ownerName: data["ownerName"] as String,
        secretKey: data["secretKey"] as String,
        iv: data["iv"] as String,
        documentName: data["documentName"] as String,
        documentSize: data["documentSize"] as String,
        ownerId: data["ownerId"] as String,
        createdOn: (data["createdOn"] as Timestamp).toDate(),
        documentId: doc.id,
        sharedEmailIds: List<String>.from(data["sharedEmailIds"]),
        documentPermission:
            DocumentPermission.values.byName(data["documentPermission"]),
        sourceUrl: data.containsKey("sourceUrl") ? data["sourceUrl"] : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createNewUser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.id).set({
        "emailId": user.emailId,
        "photoUrl": user.photoUrl,
        "name": user.name,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // static Future<Promotional> getPromotionalLinks() async {
  //   try {
  //     DocumentSnapshot _doc =
  //         await _firestore.collection("dashboard").doc("promotionList").get();

  //     Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

  //     return Promotional(
  //       thumbnailLinks: List<String>.from(_data["thumbnailLinks"]),
  //       shareUrls: List<String>.from(_data["shareUrls"]),
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // static Future<DashboardModel> getDashboard({
  //   required String collection,
  //   required String uid,
  //   required String listName,
  //   required bool isCache,
  // }) async {
  //   try {
  //     DocumentSnapshot _doc = await _firestore
  //         .collection(collection)
  //         .doc(uid)
  //         .get(GetOptions(
  //             source: isCache ? Source.cache : Source.serverAndCache));
  //     if (!_doc.exists) {
  //       _doc = await _firestore
  //           .collection(collection)
  //           .doc(uid)
  //           .get(const GetOptions(source: Source.serverAndCache));
  //     }
  //     Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

  //     return DashboardModel(
  //       dashboardList: List<String>.from(_data[listName]),
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
      {required DocumentModel documentModel,
      required String collection}) async {
    try {
      return await _firestore.collection(collection).add(
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
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateDocumentPermission({
    String? documentId,
    List<String>? emailIds,
    required DocumentPermission documentPermission,
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(
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
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set({
        "sourceUrl": sourceUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createViewsAndUploads({
    String? documentId,
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(
        {
          "views": 0,
          "uploads": 1,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteViewsAndUploads({
    String? documentId,
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateViews({
    String? documentID,
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentID).update(
        {
          "views": FieldValue.increment(1),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUploads({
    String? documentID,
    required String collection,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentID).update(
        {
          "uploads": FieldValue.increment(1),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ViewsModel> readViewsAndUploads({
    String? documentID,
    required String collection,
  }) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collection).doc(documentID).get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return ViewsModel(
        views: data["views"] as int?,
        numberOfUploads: data["uploads"] as int?,
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
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      return doc.exists ? false : true;
    } catch (e) {
      rethrow;
    }
  }

  // static Future<Book> getBook(
  //     {required String uid, required bool isCache}) async {
  //   try {
  //     DocumentSnapshot _doc = await _firestore.collection("books").doc(uid).get(
  //         GetOptions(source: isCache ? Source.cache : Source.serverAndCache));

  //     if (!_doc.exists) {
  //       _doc = await _firestore
  //           .collection("books")
  //           .doc(uid)
  //           .get(const GetOptions(source: Source.serverAndCache));
  //     }

  //     Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

  //     return Book(
  //       bookName: _data["bookName"] as String,
  //       chapterNames: List<String>.from(_data["chapterNames"]),
  //       chapterUids: List<String>.from(_data["chapterLinks"]),
  //       classNumber: _data["classNumber"] as int,
  //       //amazonBuyLink: _data["amazonBuyLink"] as String,
  //       //  gdriveLink:
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<UserModel> getUser(String uid) async {
  //   try {
  //     DocumentSnapshot _doc = await _firestore
  //         .collection("users")
  //         .doc(uid)
  //         .get(const GetOptions(source: Source.cache));
  //     if (!_doc.exists) {
  //       _doc = await _firestore
  //           .collection("users")
  //           .doc(uid)
  //           .get(const GetOptions(source: Source.serverAndCache));
  //     }
  //     Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

  //     return UserModel(
  //       emailId: _data["emailId"] as String,
  //       photoUrl: _data["photoUrl"] as String,
  //       name: _data["name"] as String,
  //       id: _doc.id,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<UserModel> getUserFromServer(String uid) async {
  //   try {
  //     DocumentSnapshot _doc = await _firestore
  //         .collection("users")
  //         .doc(uid)
  //         .get(const GetOptions(source: Source.serverAndCache));

  //     Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;

  //     return UserModel(
  //       emailId: _data["emailId"] as String,
  //       photoUrl: _data["photoUrl"] as String,
  //       name: _data["name"] as String,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
      Stream<DocumentSnapshot> snapshot =
          _firestore.collection("gullak").doc(uid).snapshots();

      return snapshot.map((doc) {
        if (!doc.exists) {
          createGullak(uid).then((value) => _firestore
              .collection("gullak")
              .doc(uid)
              .snapshots()
              .map((event) => doc = event));
        }
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return GullakModel(
          sikka: data["sikka"],
          withdrawalLink:
              data.containsKey("withdrawalLink") ? data["withdrawalLink"] : "",
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateSikka(
      {required String uid, required num increment}) async {
    try {
      await _firestore.collection("gullak").doc(uid).update(
        {
          "sikka": FieldValue.increment(increment),
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
