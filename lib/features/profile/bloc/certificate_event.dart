import 'package:equatable/equatable.dart';
import '../models/certificate.dart';

abstract class CertificateEvent extends Equatable {
  const CertificateEvent();

  @override
  List<Object?> get props => [];
}

class CertificateLoadRequested extends CertificateEvent {
  final String userId;

  const CertificateLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CertificateDownloadRequested extends CertificateEvent {
  final Certificate certificate;

  const CertificateDownloadRequested({required this.certificate});

  @override
  List<Object?> get props => [certificate];
}

class CertificateGenerateRequested extends CertificateEvent {
  final String userId;
  final String courseName;
  final String title;
  final String description;

  const CertificateGenerateRequested({
    required this.userId,
    required this.courseName,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [userId, courseName, title, description];
}

