import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ed_wise/features/profile/bloc/certificate_bloc.dart';
import 'package:ed_wise/features/profile/bloc/certificate_event.dart';
import 'package:ed_wise/features/profile/bloc/certificate_state.dart';
import 'package:ed_wise/core/repositories/certificate_repository.dart';
import 'package:ed_wise/features/profile/models/certificate.dart';

import 'certificate_bloc_test.mocks.dart';

@GenerateMocks([CertificateRepository])
void main() {
  late MockCertificateRepository mockRepository;
  late List<Certificate> mockCertificates;
  late Certificate mockCertificate;

  setUp(() {
    mockRepository = MockCertificateRepository();
    
    mockCertificate = Certificate(
      id: 'cert_1',
      userId: 'user_1',
      certificateNumber: 'CERT-20240101-00001',
      courseName: 'Test Course',
      title: 'Test Certificate',
      description: 'Test Description',
      issuedDate: DateTime.now(),
      certificateUrl: 'https://example.com/cert.pdf',
      status: CertificateStatus.active,
      metadata: {},
    );
    
    mockCertificates = [mockCertificate];
  });

  group('CertificateBloc', () {
    test('initial state is CertificateInitial', () {
      expect(
        CertificateBloc(certificateRepository: mockRepository).state,
        equals(const CertificateInitial()),
      );
    });

    blocTest<CertificateBloc, CertificateState>(
      'emits [CertificateLoading, CertificateLoaded] when certificates load successfully',
      build: () {
        when(mockRepository.getCertificates(any))
            .thenAnswer((_) async => mockCertificates);
        return CertificateBloc(certificateRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const CertificateLoadRequested(userId: 'user_1')),
      expect: () => [
        const CertificateLoading(),
        CertificateLoaded(certificates: mockCertificates),
      ],
    );

    blocTest<CertificateBloc, CertificateState>(
      'emits [CertificateLoading, CertificateError] when load fails',
      build: () {
        when(mockRepository.getCertificates(any))
            .thenThrow(Exception('Failed to load'));
        return CertificateBloc(certificateRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const CertificateLoadRequested(userId: 'user_1')),
      expect: () => [
        const CertificateLoading(),
        const CertificateError(message: 'Exception: Failed to load'),
      ],
    );

    blocTest<CertificateBloc, CertificateState>(
      'emits [CertificateDownloading, CertificateDownloaded] when download succeeds',
      build: () {
        when(mockRepository.downloadCertificate(any))
            .thenAnswer((_) async => '/path/to/certificate.pdf');
        return CertificateBloc(certificateRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        CertificateDownloadRequested(certificate: mockCertificate),
      ),
      expect: () => [
        CertificateDownloading(certificate: mockCertificate),
        const CertificateDownloaded(filePath: '/path/to/certificate.pdf'),
      ],
    );
  });
}

