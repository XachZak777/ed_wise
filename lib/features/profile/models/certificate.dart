import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String courseName;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String certificateUrl;
  final String certificateNumber;
  final CertificateStatus status;
  final Map<String, dynamic> metadata;

  Certificate({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.courseName,
    required this.issuedDate,
    this.expiryDate,
    required this.certificateUrl,
    required this.certificateNumber,
    required this.status,
    required this.metadata,
  });

  factory Certificate.fromMap(Map<String, dynamic> map, String id) {
    return Certificate(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseName: map['courseName'] ?? '',
      issuedDate: (map['issuedDate'] as Timestamp).toDate(),
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      certificateUrl: map['certificateUrl'] ?? '',
      certificateNumber: map['certificateNumber'] ?? '',
      status: CertificateStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CertificateStatus.active,
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'courseName': courseName,
      'issuedDate': Timestamp.fromDate(issuedDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'certificateUrl': certificateUrl,
      'certificateNumber': certificateNumber,
      'status': status.name,
      'metadata': metadata,
    };
  }

  Certificate copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? courseName,
    DateTime? issuedDate,
    DateTime? expiryDate,
    String? certificateUrl,
    String? certificateNumber,
    CertificateStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return Certificate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      courseName: courseName ?? this.courseName,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum CertificateStatus {
  active,
  expired,
  revoked,
}

