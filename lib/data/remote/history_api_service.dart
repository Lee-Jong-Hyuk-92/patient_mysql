        // C:\Users\user\Desktop\0703flutter_v2\lib\data\remote\history_api_service.dart

        import '../../../core/result.dart';

        class HistoryApiService {
          final String baseUrl;

          HistoryApiService({required this.baseUrl});

          // 가상의 진단 기록 데이터
          final List<Map<String, dynamic>> _mockHistoryRecords = [
            {
              'id': 'hist001',
              'date': '2024-06-20T10:00:00Z',
              'summary': '치아 21번 초기 충치 의심',
              'detail': '왼쪽 위 앞니에 작은 검은 점이 발견되어 초기 충치가 의심됩니다. 정밀 검사가 필요합니다.',
              'thumbnailUrl': 'https://placehold.co/100x100/FF5733/FFFFFF?text=Hist1',
              'imageUrl': 'https://placehold.co/600x400/FF5733/FFFFFF?text=History+Detail+1',
            },
            {
              'id': 'hist002',
              'date': '2024-05-15T14:30:00Z',
              'summary': '잇몸 염증 소견',
              'detail': '아래쪽 잇몸에 약간의 붓기와 출혈이 관찰됩니다. 잇몸 염증 초기 단계로 보입니다. 스케일링이 필요할 수 있습니다.',
              'thumbnailUrl': 'https://placehold.co/100x100/33FF57/000000?text=Hist2',
              'imageUrl': 'https://placehold.co/600x400/33FF57/000000?text=History+Detail+2',
            },
            {
              'id': 'hist003',
              'date': '2024-04-01T09:00:00Z',
              'summary': '치아 착색 확인',
              'detail': '커피 섭취로 인한 치아 착색이 확인되었습니다. 미백 치료를 고려해볼 수 있습니다.',
              'thumbnailUrl': 'https://placehold.co/100x100/3366FF/FFFFFF?text=Hist3',
              'imageUrl': 'https://placehold.co/600x400/3366FF/FFFFFF?text=History+Detail+3',
            },
          ];

          Future<Result<List<Map<String, dynamic>>>> getHistoryRecords() async {
            await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
            return Success(_mockHistoryRecords);
          }

          Future<Result<Map<String, dynamic>>> getHistoryRecordDetail(String id) async {
            await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
            final record = _mockHistoryRecords.firstWhere((r) => r['id'] == id, orElse: () => {});
            if (record.isNotEmpty) {
              return Success(record);
            } else {
              return const Failure('해당 진단 내역을 찾을 수 없습니다.');
            }
          }
        }
        