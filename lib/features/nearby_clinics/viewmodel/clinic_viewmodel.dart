// C:\Users\user\Desktop\0703flutter_v2\lib\features\nearby_clinics\viewmodel\clinic_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/result.dart';
import '../../../data/remote/clinic_api_service.dart'; // 이 경로가 정확해야 합니다!

// 치과 데이터 모델
class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String openingHours;
  final double rating;
  final int reviewCount;
  final double distance; // km
  final String imageUrl;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      openingHours: json['openingHours'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(), // num to int
      distance: (json['distance'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class ClinicViewModel extends ChangeNotifier {
  final ClinicApiService _apiService;
  List<Clinic> _allClinics = [];
  List<Clinic> _filteredClinics = [];
  Clinic? _currentClinic;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Clinic> get filteredClinics => _filteredClinics;
  Clinic? get currentClinic => _currentClinic;

  ClinicViewModel({required String baseUrl}) : _apiService = ClinicApiService(baseUrl: baseUrl);

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 모든 치과 정보 가져오기
  Future<void> fetchClinics() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _apiService.getClinics();
      if (result is Success<List<Map<String, dynamic>>>) {
        _allClinics = result.data.map((json) => Clinic.fromJson(json)).toList();
        filterAndSortClinics('', 'distance'); // 초기 필터링 및 정렬
      } else if (result is Failure<List<Map<String, dynamic>>>) { // ✅ 꺾쇠 괄호 개수 수정 확인
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = '치과 정보를 불러오는 중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 특정 치과 상세 정보 가져오기
  Future<void> fetchClinicDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _currentClinic = null; // 상세 정보 로드 전 초기화
    try {
      final result = await _apiService.getClinicDetail(id);
      if (result is Success<Map<String, dynamic>>) {
        _currentClinic = Clinic.fromJson(result.data);
      } else if (result is Failure<Map<String, dynamic>>) { // ✅ 꺾쇠 괄호 개수 수정 확인
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = '치과 상세 정보를 불러오는 중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 치과 목록 필터링 및 정렬
  void filterAndSortClinics(String query, String sortBy) {
    List<Clinic> tempClinics = List.from(_allClinics);

    // 필터링
    if (query.isNotEmpty) {
      tempClinics = tempClinics.where((clinic) =>
          clinic.name.toLowerCase().contains(query.toLowerCase()) ||
          clinic.address.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

    // 정렬
    if (sortBy == 'distance') {
      tempClinics.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (sortBy == 'popularity') {
      tempClinics.sort((a, b) => b.rating.compareTo(a.rating)); // 평점 높은 순
    }

    _filteredClinics = tempClinics;
    notifyListeners();
  }

  // 예약 가능한 시간 목록 (가상)
  List<String> getAvailableTimes(DateTime date) {
    // 실제로는 API에서 해당 날짜의 예약 가능 시간을 가져와야 합니다.
    // 여기서는 간단히 몇 가지 시간을 반환합니다.
    if (date.weekday == DateTime.sunday || date.weekday == DateTime.saturday) {
      return []; // 주말은 예약 불가
    }
    return ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];
  }

  // 예약 확정 (가상)
  Future<void> bookAppointment({
    required String clinicId,
    required DateTime date,
    required String time,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _apiService.bookAppointment(
        clinicId: clinicId,
        date: date,
        time: time,
      );

      if (result is Success<bool>) {
        _successMessage = '예약이 완료되었습니다. 확정 시 알림으로 안내해 드립니다.';
      } else if (result is Failure<bool>) {
        _errorMessage = '예약 실패: ${result.message}';
      }
    } catch (e) {
      _errorMessage = '예상치 못한 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
}
