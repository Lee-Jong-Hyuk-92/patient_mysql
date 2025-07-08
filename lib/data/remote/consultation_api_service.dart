        // C:\Users\user\Desktop\0703flutter_v2\lib\data\remote\consultation_api_service.dart

        import '../../../core/result.dart';

        class ConsultationApiService {
          final String baseUrl;

          ConsultationApiService({required this.baseUrl});

          // 가상의 비대면 진단 데이터
          final List<Map<String, dynamic>> _mockConsultations = [
            {
              'id': 'cons001',
              'requestDate': '2024-06-25T11:00:00Z',
              'summary': '치아 11번 통증',
              'aiPrediction': '치아 11번 주변 잇몸 염증 가능성',
              'imageUrl': 'https://placehold.co/600x400/FF5733/FFFFFF?text=Consultation+1',
              'doctorResponse': '사진상으로는 명확한 충치는 보이지 않으나, 잇몸 염증이 의심됩니다. 가까운 치과에 내원하여 정확한 진단을 받아보시는 것이 좋습니다.',
            },
            {
              'id': 'cons002',
              'requestDate': '2024-06-20T15:00:00Z',
              'summary': '어금니 시림 증상',
              'aiPrediction': '치아 36번 마모 또는 초기 충치 가능성',
              'imageUrl': 'https://placehold.co/600x400/33FF57/000000?text=Consultation+2',
              'doctorResponse': null, // 아직 의사 답변 없음
            },
            {
              'id': 'cons003',
              'requestDate': '2024-06-10T09:00:00Z',
              'summary': '사랑니 주변 붓기',
              'aiPrediction': '사랑니 주변 염증',
              'imageUrl': 'https://placehold.co/600x400/3366FF/FFFFFF?text=Consultation+3',
              'doctorResponse': '사랑니 주변에 염증이 진행된 것으로 보입니다. 통증이 심해지면 발치를 고려해야 할 수 있으니 치과 방문을 권합니다.',
            },
          ];

          Future<Result<List<Map<String, dynamic>>>> getConsultations() async {
            await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
            return Success(_mockConsultations);
          }

          Future<Result<Map<String, dynamic>>> getConsultationDetail(String id) async {
            await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
            final consultation = _mockConsultations.firstWhere((c) => c['id'] == id, orElse: () => {});
            if (consultation.isNotEmpty) {
              return Success(consultation);
            } else {
              return const Failure('해당 비대면 진단 결과를 찾을 수 없습니다.');
            }
          }
        }
        