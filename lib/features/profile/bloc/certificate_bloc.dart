import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/certificate_repository.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final CertificateRepository _certificateRepository;

  CertificateBloc({CertificateRepository? certificateRepository})
      : _certificateRepository = certificateRepository ?? CertificateRepository.instance,
        super(const CertificateInitial()) {
    on<CertificateLoadRequested>(_onCertificateLoadRequested);
    on<CertificateDownloadRequested>(_onCertificateDownloadRequested);
    on<CertificateGenerateRequested>(_onCertificateGenerateRequested);
  }

  Future<void> _onCertificateLoadRequested(
    CertificateLoadRequested event,
    Emitter<CertificateState> emit,
  ) async {
    emit(const CertificateLoading());
    try {
      final certificates = await _certificateRepository.getCertificates(event.userId);
      emit(CertificateLoaded(certificates: certificates));
    } catch (e) {
      emit(CertificateError(message: e.toString()));
    }
  }

  Future<void> _onCertificateDownloadRequested(
    CertificateDownloadRequested event,
    Emitter<CertificateState> emit,
  ) async {
    emit(CertificateDownloading(certificate: event.certificate));
    try {
      final filePath = await _certificateRepository.downloadCertificate(event.certificate);
      emit(CertificateDownloaded(filePath: filePath));
    } catch (e) {
      emit(CertificateError(message: e.toString()));
    }
  }

  Future<void> _onCertificateGenerateRequested(
    CertificateGenerateRequested event,
    Emitter<CertificateState> emit,
  ) async {
    emit(const CertificateLoading());
    try {
      final certificate = await _certificateRepository.generateCertificate(
        userId: event.userId,
        courseName: event.courseName,
        title: event.title,
        description: event.description,
      );
      emit(CertificateGenerated(certificate: certificate));
    } catch (e) {
      emit(CertificateError(message: e.toString()));
    }
  }
}

