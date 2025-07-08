// C:\Users\user\Desktop\0703flutter_v2\lib\features\non_face_to_face\viewmodel\consultation_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/result.dart';
import '../../../data/remote/consultation_api_service.dart'; // ✅ 이 경로가 정확해야 합니다!

// 비대면 진단 데이터 모델
class Consultation {
  final String id;
  final DateTime requestDate;
  final String summary;
  final String aiPrediction;
  final String imageUrl;
  final String? doctorResponse; // 의사 답변 (선택 사항)
  final bool hasDoctorResponse;

  Consultation({
    required this.id,
    required this.requestDate,
    required this.summary,
    required this.aiPrediction,
    required this.imageUrl,
    this.doctorResponse,
  }) : hasDoctorResponse = doctorResponse != null && doctorResponse.isNotEmpty;

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      summary: json['summary'] as String,
      aiPrediction: json['aiPrediction'] as String,
      imageUrl: json['imageUrl'] as String,
      doctorResponse: json['doctorResponse'] as String?,
    );
  }
}

class ConsultationViewModel extends ChangeNotifier {
  final ConsultationApiService _apiService;
  List<Consultation> _consultations = [];
  Consultation? _currentConsultation;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Consultation> get consultations => _consultations;
  Consultation? get currentConsultation => _currentConsultation;

  ConsultationViewModel({required String baseUrl}) : _apiService = ConsultationApiService(baseUrl: baseUrl);

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 모든 비대면 진단 요청 가져오기
  Future<void> fetchConsultations() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _apiService.getConsultations();
      if (result is Success<List<Map<String, dynamic>>>) {
        _consultations = result.data.map((json) => Consultation.fromJson(json)).toList();
        _consultations.sort((a, b) => b.requestDate.compareTo(a.requestDate)); // 최신순 정렬
      } else if (result is Failure<List<Map<String, dynamic>>>) { // ✅ 꺾쇠 괄호 개수 수정 확인
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = '비대면 진단 요청을 불러오는 중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 특정 비대면 진단 상세 정보 가져오기
  Future<void> fetchConsultationDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _currentConsultation = null; // 상세 정보 로드 전 초기화
    try {
      final result = await _apiService.getConsultationDetail(id);
      if (result is Success<Map<String, dynamic>>) {
        _currentConsultation = Consultation.fromJson(result.data);
      } else if (result is Failure<Map<String, dynamic>>) { // ✅ 꺾쇠 괄호 개수 수정 확인
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = '비대면 진단 상세 정보를 불러오는 중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }
}
