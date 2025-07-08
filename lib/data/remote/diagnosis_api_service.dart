        // C:\Users\user\Desktop\0703flutter_v2\lib\data\remote\diagnosis_api_service.dart

        import '../../../core/result.dart';

        class DiagnosisApiService {
          final String baseUrl;

          DiagnosisApiService({required this.baseUrl});

          final List<Map<String, dynamic>> _mockDiagnosisResults = [
            {
              'id': 'diag001',
              'summary': '치아 21번 초기 충치 의심',
              'originalImageUrl': 'https://placehold.co/600x400/FF5733/FFFFFF?text=Original+Image+1',
              'overlayImageUrl': 'https://placehold.co/600x400/33FF57/000000?text=Overlay+Image+1',
            },
            {
              'id': 'diag002',
              'summary': '잇몸 염증 소견',
              'originalImageUrl': 'https://placehold.co/600x400/3366FF/FFFFFF?text=Original+Image+2',
              'overlayImageUrl': 'https://placehold.co/600x400/FF33FF/000000?text=Overlay+Image+2',
            },
          ];


          Future<Result<Map<String, dynamic>>> getDiagnosisResult() async {
            await Future.delayed(const Duration(seconds: 2)); // API 호출 시뮬레이션
            // 실제로는 '$baseUrl/diagnosis/result' 같은 엔드포인트로 HTTP 요청
            if (_mockDiagnosisResults.isNotEmpty) {
              return Success(_mockDiagnosisResults.first); // 첫 번째 가상 결과 반환
            } else {
              return const Failure('진단 결과를 불러오는데 실패했습니다. 다시 시도해주세요.');
            }
          }

          Future<Result<bool>> saveImageToDevice(String imageUrl) async {
            await Future.delayed(const Duration(seconds: 1)); // 저장 지연 시뮬레이션
            if (imageUrl.isNotEmpty) {
              print('Image saved: $imageUrl');
              return const Success(true);
            } else {
              return const Failure('저장할 이미지 URL이 유효하지 않습니다.');
            }
          }

          Future<Result<bool>> sendNonFaceToFaceRequest(String summary, String originalImageUrl, String? overlayImageUrl) async {
            await Future.delayed(const Duration(seconds: 2)); // 네트워크 지연 시뮬레이션
            print('비대면 진단 요청 전송됨:');
            print('요약: $summary');
            print('원본 이미지: $originalImageUrl');
            print('오버레이 이미지: $overlayImageUrl');
            return const Success(true);
          }
        }
        