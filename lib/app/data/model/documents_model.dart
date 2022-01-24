class DocumentModel {
  final String? ownerId;
  final String? documentName;
  final String? ownerName;
  final String? ownerEmailId;
  final String? ownerPhotoUrl;
  final String? secretKey;
  final String? iv;
  final String? documentSize;
  final String? documentId;
  final DateTime? createdOn;
  final DocumentPermission documentPermission;
  final List<String>? sharedEmailIds;

  DocumentModel({
    this.ownerId,
    this.documentName,
    this.ownerName,
    this.ownerEmailId,
    this.ownerPhotoUrl,
    this.secretKey,
    this.iv,
    this.documentSize,
    this.documentId,
    this.createdOn,
    this.documentPermission = DocumentPermission.private,
    this.sharedEmailIds,
  });
}

enum DocumentPermission { private, public, shared }
