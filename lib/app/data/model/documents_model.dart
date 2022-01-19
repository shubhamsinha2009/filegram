class DocumentModel {
  final String? ownerId;
  final String? documentName;
  final String? ownerName;
  final String? ownerPhotoUrl;
  final String? secretKey;
  final String? iv;
  final String? documentSize;
  final String? documentId;
  final DateTime? createdOn;
  // final String? documentPermission;
  // final List<String>? sharedIds;

  DocumentModel({
    this.ownerId,
    this.documentName,
    this.ownerName,
    this.ownerPhotoUrl,
    this.secretKey,
    this.iv,
    this.documentSize,
    this.documentId,
    this.createdOn,
    // this.documentPermission,
    // this.sharedIds,
  });
}
