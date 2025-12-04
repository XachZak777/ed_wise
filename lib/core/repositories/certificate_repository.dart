import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../features/profile/models/certificate.dart';
import '../../features/profile/repositories/mock_certificate_repository.dart';

abstract class CertificateRepository {
  static CertificateRepository get instance {
    if (AppConfig.useMockData) {
      return MockCertificateRepository();
    }
    return FirebaseCertificateRepository();
  }

  Future<List<Certificate>> getCertificates(String userId);
  Future<Certificate> generateCertificate({
    required String userId,
    required String courseName,
    required String title,
    required String description,
  });
  Future<String> downloadCertificate(Certificate certificate);
}

class FirebaseCertificateRepository implements CertificateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<List<Certificate>> getCertificates(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('certificates')
          .where('userId', isEqualTo: userId)
          .orderBy('issuedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Certificate.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load certificates: $e');
    }
  }

  @override
  Future<Certificate> generateCertificate({
    required String userId,
    required String courseName,
    required String title,
    required String description,
  }) async {
    try {
      final certificateNumber = 'CERT-${DateTime.now().millisecondsSinceEpoch}';
      final certificate = Certificate(
        id: '',
        userId: userId,
        title: title,
        description: description,
        courseName: courseName,
        issuedDate: DateTime.now(),
        expiryDate: null,
        certificateUrl: '',
        certificateNumber: certificateNumber,
        status: CertificateStatus.active,
        metadata: {},
      );

      // Generate certificate PDF (simplified - in production, use a PDF generation library)
      final certificateUrl = await _generateCertificatePDF(certificate);

      final docRef = await _firestore.collection('certificates').add(
        certificate.copyWith(
          certificateUrl: certificateUrl,
        ).toMap(),
      );

      return certificate.copyWith(id: docRef.id, certificateUrl: certificateUrl);
    } catch (e) {
      throw Exception('Failed to generate certificate: $e');
    }
  }

  @override
  Future<String> downloadCertificate(Certificate certificate) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Download certificate
      final response = await http.get(Uri.parse(certificate.certificateUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download certificate');
      }

      // Save to device
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${certificate.certificateNumber}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      return file.path;
    } catch (e) {
      throw Exception('Failed to download certificate: $e');
    }
  }

  Future<String> _generateCertificatePDF(Certificate certificate) async {
    // Simplified PDF generation: create a minimal text-based PDF-like content
    // and upload it to Firebase Storage, then return its download URL.
    final ref =
        _storage.ref().child('certificates/${certificate.certificateNumber}.pdf');

    // In a production app, replace this with real PDF bytes from a PDF library.
    final content = '''
EdWise Certificate

Certificate Number: ${certificate.certificateNumber}
User ID: ${certificate.userId}
Course: ${certificate.courseName}
Title: ${certificate.title}
Description: ${certificate.description}
Issued Date: ${certificate.issuedDate.toIso8601String()}
''';

    final bytes = Uint8List.fromList(utf8.encode(content));

    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: 'application/pdf'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

