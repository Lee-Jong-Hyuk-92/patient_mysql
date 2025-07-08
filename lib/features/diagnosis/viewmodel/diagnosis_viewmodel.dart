// C:\Users\user\Desktop\0703flutter_v2\lib\features\diagnosis\viewmodel\diagnosis_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/result.dart'; // Result 클래스 임포트
import '../../../data/remote/diagnosis_api_service.dart'; // ✅ 이 경로가 정확해야 합니다!

// 진단 결과 데이터를 담을 모델 (간단화)
class DiagnosisResult {
  final String summary;
  final String originalImageUrl;
  final String? overlayImageUrl; // 병변 오버레이 이미지 URL (선택 사항)

  DiagnosisResult({
    required this.summary,
    required this.originalImageUrl,
    this.overlayImageUrl,
  });
}

class DiagnosisViewModel extends ChangeNotifier { // ✅ 'extㅁnds' -> 'extends' 수정됨
  final DiagnosisApiService _apiService; // final로 변경하고 생성자에서 초기화

  // ✅ baseUrl을 생성자로 받도록 수정
  DiagnosisViewModel({required String baseUrl})
      : _apiService = DiagnosisApiService(baseUrl: baseUrl); // baseUrl을 DiagnosisApiService 생성자에 전달

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  DiagnosisResult? _diagnosisResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DiagnosisResult? get diagnosisResult => _diagnosisResult;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // 진단 결과 데이터 로드
  Future<void> fetchDiagnosisResult() async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      // 실제 API 호출 대신 가상 데이터 사용
      final result = await _apiService.getDiagnosisResult();

      if (result is Success<Map<String, dynamic>>) {
        final data = result.data;
        _diagnosisResult = DiagnosisResult(
          summary: data['summary'] ?? '진단 결과 요약 없음',
          originalImageUrl: data['originalImageUrl'] ?? 'https://placehold.co/300x200/png?text=Original+Image',
          overlayImageUrl: data['overlayImageUrl'],
        );
        _successMessage = '진단 결과가 성공적으로 로드되었습니다.';
      } else if (result is Failure<Map<String, dynamic>>) {
        _errorMessage = '진단 결과 로드 실패: ${result.message}';
      }
    } catch (e) {
      _errorMessage = '예상치 못한 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 이미지 저장 (가상)
  Future<void> saveImage(String imageUrl) async {
    if (imageUrl.isEmpty || imageUrl == 'https://placehold.co/300x200/png?text=Original+Image' || imageUrl == 'https://placehold.co/300x200/png?text=Diagnosis+Result') {
      _errorMessage = '저장할 이미지가 유효하지 않습니다.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _apiService.saveImageToDevice(imageUrl);
      if (result is Success<bool>) {
        _successMessage = '이미지가 성공적으로 저장되었습니다.';
      } else if (result is Failure<bool>) {
        _errorMessage = '이미지 저장 실패: ${result.message}';
      }
    } catch (e) {
      _errorMessage = '예상치 못한 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 비대면 진단 신청 (가상)
  Future<void> requestNonFaceToFaceDiagnosis() async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _apiService.sendNonFaceToFaceRequest(
        _diagnosisResult?.summary ?? '진단 요약 없음',
        _diagnosisResult?.originalImageUrl ?? '',
        _diagnosisResult?.overlayImageUrl ?? '',
      );

      if (result is Success<bool>) {
        _successMessage = '비대면 진단 요청이 의사에게 전달되었습니다. 답변이 오면 알림으로 알려드릴게요.';
      } else if (result is Failure<bool>) {
        _errorMessage = '비대면 진단 요청 실패: ${result.message}';
      }
    } catch (e) {
      _errorMessage = '예상치 못한 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
