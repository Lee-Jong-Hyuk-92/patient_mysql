        // C:\Users\user\Desktop\0703flutter_v2\lib\data\remote\clinic_api_service.dart

        import '../../../core/result.dart';

        class ClinicApiService {
          final String baseUrl;

          ClinicApiService({required this.baseUrl});

          // 가상의 치과 데이터
          final List<Map<String, dynamic>> _mockClinics = [
            {
              'id': 'clinic001',
              'name': '미소치과',
              'address': '서울시 강남구 테헤란로 123',
              'phone': '02-1234-5678',
              'openingHours': '월~금 09:00-18:00',
              'rating': 4.8,
              'reviewCount': 120,
              'distance': 2.5,
              'imageUrl': 'https://placehold.co/600x400/FF5733/FFFFFF?text=Clinic+1',
            },
            {
              'id': 'clinic002',
              'name': '튼튼치과',
              'address': '서울시 서초구 서초대로 456',
              'phone': '02-9876-5432',
              'openingHours': '월~토 10:00-19:00',
              'rating': 4.5,
              'reviewCount': 80,
              'distance': 1.2,
              'imageUrl': 'https://placehold.co/600x400/33FF57/000000?text=Clinic+2',
            },
            {
              'id': 'clinic003',
              'name': '밝은치과',
              'address': '서울시 송파구 올림픽로 789',
              'phone': '02-1111-2222',
              'openingHours': '화~금 09:30-18:30',
              'rating': 4.9,
              'reviewCount': 200,
              'distance': 5.1,
              'imageUrl': 'https://placehold.co/600x400/3366FF/FFFFFF?text=Clinic+3',
            },
          ];

          Future<Result<List<Map<String, dynamic>>>> getClinics() async {
            await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
            return Success(_mockClinics);
          }

          Future<Result<Map<String, dynamic>>> getClinicDetail(String id) async {
            await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
            final clinic = _mockClinics.firstWhere((c) => c['id'] == id, orElse: () => {});
            if (clinic.isNotEmpty) {
              return Success(clinic);
            } else {
              return const Failure('해당 치과 정보를 찾을 수 없습니다.');
            }
          }

          Future<Result<bool>> bookAppointment({
            required String clinicId,
            required DateTime date,
            required String time,
          }) async {
            await Future.delayed(const Duration(seconds: 2)); // 예약 처리 시뮬레이션
            print('예약 요청: 치과 ID: $clinicId, 날짜: $date, 시간: $time');
            return const Success(true); // 성공으로 가정
          }
        }
        