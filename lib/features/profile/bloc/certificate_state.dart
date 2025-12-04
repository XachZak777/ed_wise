import 'package:equatable/equatable.dart';
import '../models/certificate.dart';

abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

class CertificateInitial extends CertificateState {
  const CertificateInitial();
}

class CertificateLoading extends CertificateState {
  const CertificateLoading();
}

class CertificateLoaded extends CertificateState {
  final List<Certificate> certificates;

  const CertificateLoaded({required this.certificates});

  @override
  List<Object?> get props => [certificates];
}

class CertificateDownloading extends CertificateState {
  final Certificate certificate;

  const CertificateDownloading({required this.certificate});

  @override
  List<Object?> get props => [certificate];
}

class CertificateDownloaded extends CertificateState {
  final String filePath;

  const CertificateDownloaded({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class CertificateGenerated extends CertificateState {
  final Certificate certificate;

  const CertificateGenerated({required this.certificate});

  @override
  List<Object?> get props => [certificate];
}

class CertificateError extends CertificateState {
  final String message;

  const CertificateError({required this.message});

  @override
  List<Object?> get props => [message];
}

