import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/app_config.dart';
import '../../../core/repositories/certificate_repository.dart';
import '../models/certificate.dart';

class MockCertificateRepository implements CertificateRepository {
  final List<Certificate> _mockCertificates = [];

  MockCertificateRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    
    // Generate unique certificate IDs in format: CERT-YYYYMMDD-XXXXX
    String generateCertId() {
      final dateStr = now.toIso8601String().substring(0, 10).replaceAll('-', '');
      final random = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      return 'CERT-$dateStr-$random';
    }

    _mockCertificates.addAll([
      Certificate(
        id: 'cert_1',
        userId: 'demo_user',
        title: 'Flutter Development Certificate',
        description: 'Successfully completed Flutter Development course with hands-on projects and real-world applications',
        courseName: 'Flutter Development',
        issuedDate: now.subtract(const Duration(days: 30)),
        expiryDate: null,
        certificateUrl: 'https://example.com/certificates/cert_1.pdf',
        certificateNumber: generateCertId(),
        status: CertificateStatus.active,
        metadata: {
          'instructor': 'John Doe',
          'duration': '40 hours',
          'grade': 'A+',
          'completionRate': '100%',
        },
      ),
      Certificate(
        id: 'cert_2',
        userId: 'demo_user',
        title: 'Dart Programming Certificate',
        description: 'Successfully completed Dart Programming course covering advanced topics and best practices',
        courseName: 'Dart Programming',
        issuedDate: now.subtract(const Duration(days: 60)),
        expiryDate: null,
        certificateUrl: 'https://example.com/certificates/cert_2.pdf',
        certificateNumber: generateCertId(),
        status: CertificateStatus.active,
        metadata: {
          'instructor': 'Jane Smith',
          'duration': '30 hours',
          'grade': 'A',
          'completionRate': '100%',
        },
      ),
      Certificate(
        id: 'cert_3',
        userId: 'demo_user',
        title: 'Firebase Integration Certificate',
        description: 'Successfully completed Firebase Integration course including Authentication, Firestore, and Storage',
        courseName: 'Firebase Integration',
        issuedDate: now.subtract(const Duration(days: 90)),
        expiryDate: null,
        certificateUrl: 'https://example.com/certificates/cert_3.pdf',
        certificateNumber: generateCertId(),
        status: CertificateStatus.active,
        metadata: {
          'instructor': 'Bob Johnson',
          'duration': '25 hours',
          'grade': 'A+',
          'completionRate': '100%',
        },
      ),
      Certificate(
        id: 'cert_4',
        userId: 'demo_user',
        title: 'State Management with BLoC Certificate',
        description: 'Mastered BLoC pattern for state management in Flutter applications',
        courseName: 'State Management with BLoC',
        issuedDate: now.subtract(const Duration(days: 15)),
        expiryDate: null,
        certificateUrl: 'https://example.com/certificates/cert_4.pdf',
        certificateNumber: generateCertId(),
        status: CertificateStatus.active,
        metadata: {
          'instructor': 'Alice Williams',
          'duration': '20 hours',
          'grade': 'A+',
          'completionRate': '100%',
        },
      ),
      Certificate(
        id: 'cert_5',
        userId: 'demo_user',
        title: 'UI/UX Design for Mobile Apps Certificate',
        description: 'Completed comprehensive UI/UX design course for mobile applications',
        courseName: 'UI/UX Design for Mobile Apps',
        issuedDate: now.subtract(const Duration(days: 45)),
        expiryDate: null,
        certificateUrl: 'https://example.com/certificates/cert_5.pdf',
        certificateNumber: generateCertId(),
        status: CertificateStatus.active,
        metadata: {
          'instructor': 'Charlie Brown',
          'duration': '35 hours',
          'grade': 'A',
          'completionRate': '100%',
        },
      ),
      Certificate(
        id: 'cert_6',
        userId: 'demo_user',
        title: 'Advanced Flutter Architecture Certificate',
        description: 'Completed advanced course on Flutter architecture patterns and best practices',
        courseName: 'Advanced Flutter Architecture',
        issuedDate: now.subtract(const Duration(days: 10)),
        expiryDate: null,
        certificateUrl: 'https://example.com/certificates/cert_6.pdf',
        certificateNumber: generateCertId(),
        status: CertificateStatus.active,
        metadata: {
          'instructor': 'Diana Prince',
          'duration': '45 hours',
          'grade': 'A+',
          'completionRate': '100%',
        },
      ),
    ]);
  }

  @override
  Future<List<Certificate>> getCertificates(String userId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    // For presentation: Show demo certificates for any user
    final userCerts = _mockCertificates.where((cert) => cert.userId == userId).toList();
    if (userCerts.isEmpty && _mockCertificates.isNotEmpty) {
      // Return demo certificates with updated userId
      return _mockCertificates.map((cert) => cert.copyWith(userId: userId)).toList();
    }
    return userCerts;
  }

  @override
  Future<Certificate> generateCertificate({
    required String userId,
    required String courseName,
    required String title,
    required String description,
  }) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    
    final now = DateTime.now();
    final dateStr = now.toIso8601String().substring(0, 10).replaceAll('-', '');
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final certNumber = 'CERT-$dateStr-$random';
    
    final certificate = Certificate(
      id: 'cert_${_mockCertificates.length + 1}',
      userId: userId,
      title: title,
      description: description,
      courseName: courseName,
      issuedDate: now,
      expiryDate: null,
      certificateUrl: 'https://example.com/certificates/cert_${_mockCertificates.length + 1}.pdf',
      certificateNumber: certNumber,
      status: CertificateStatus.active,
      metadata: {
        'instructor': 'System Instructor',
        'duration': '20 hours',
        'grade': 'A',
        'completionRate': '100%',
      },
    );

    _mockCertificates.add(certificate);
    return certificate;
  }

  @override
  Future<String> downloadCertificate(Certificate certificate) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockDataDelay));
    
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }

    // Simulate download
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${certificate.certificateNumber}.pdf');
    
    // Create a mock PDF file with certificate details
    final pdfContent = '''
CERTIFICATE OF COMPLETION

This is to certify that
${certificate.userId}

has successfully completed the course

${certificate.courseName}

Title: ${certificate.title}

Certificate Number: ${certificate.certificateNumber}
Issued Date: ${certificate.issuedDate.toLocal().toString().split(' ')[0]}

Description: ${certificate.description}

---
EdWise Educational Platform
''';
    
    await file.writeAsString(pdfContent);
    
    return file.path;
  }
}
