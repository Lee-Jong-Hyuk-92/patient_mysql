// C:\Users\user\Desktop\0703flutter_v2\lib\features\history\viewmodel\history_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/result.dart';
import '../../../data/remote/history_api_service.dart'; // 이 경로가 정확해야 합니다!

// 진단 기록 데이터 모델
class HistoryRecord {
  final String id;
  final DateTime date;
  final String summary;
  final String detail;
  final String thumbnailUrl;
  final String imageUrl;

  HistoryRecord({
    required this.id,
    required this.date,
    required this.summary,
    required this.detail,
    required this.thumbnailUrl,
    required this.imageUrl,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      summary: json['summary'] as String,
      detail: json['detail'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class HistoryViewModel extends ChangeNotifier {
  final HistoryApiService _apiService;
  List<HistoryRecord> _allHistoryRecords = [];
  List<HistoryRecord> _filteredHistoryRecords = [];
  HistoryRecord? _currentHistoryRecord;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<HistoryRecord> get filteredHistoryRecords => _filteredHistoryRecords;
  HistoryRecord? get currentHistoryRecord => _currentHistoryRecord;

  HistoryViewModel({required String baseUrl}) : _apiService = HistoryApiService(baseUrl: baseUrl);

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 모든 진단 내역 가져오기
  Future<void> fetchHistoryRecords() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _apiService.getHistoryRecords();
      if (result is Success<List<Map<String, dynamic>>>) {
        _allHistoryRecords = result.data.map((json) => HistoryRecord.fromJson(json)).toList();
        _allHistoryRecords.sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬
        _filteredHistoryRecords = List.from(_allHistoryRecords); // 초기 필터링된 목록 설정
      } else if (result is Failure<List<Map<String, dynamic>>>) { // ✅ 꺾쇠 괄호 개수 수정 확인
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = '진단 내역을 불러오는 중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 특정 진단 내역 상세 정보 가져오기
  Future<void> fetchHistoryRecordDetail(String id) async {
    _setLoading(true);
    _errorMessage = null;
    _currentHistoryRecord = null; // 상세 정보 로드 전 초기화
    try {
      final result = await _apiService.getHistoryRecordDetail(id);
      if (result is Success<Map<String, dynamic>>) {
        _currentHistoryRecord = HistoryRecord.fromJson(result.data);
      } else if (result is Failure<Map<String, dynamic>>) { // ✅ 꺾쇠 괄호 개수 수정 확인
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = '진단 내역 상세 정보를 불러오는 중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 진단 내역 필터링 및 검색
  void filterHistory(String query, DateTime? startDate, DateTime? endDate) {
    _filteredHistoryRecords = _allHistoryRecords.where((record) {
      final matchesQuery = query.isEmpty ||
          record.summary.toLowerCase().contains(query.toLowerCase()) ||
          record.detail.toLowerCase().contains(query.toLowerCase());

      final matchesDate = (startDate == null || record.date.isAfter(startDate.subtract(const Duration(days: 1)))) &&
                          (endDate == null || record.date.isBefore(endDate.add(const Duration(days: 1))));

      return matchesQuery && matchesDate;
    }).toList();
    notifyListeners();
  }
}
