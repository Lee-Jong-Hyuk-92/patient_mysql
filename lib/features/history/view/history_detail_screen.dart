// C:\Users\user\Desktop\0703flutter_v2\lib\features\history\view\history_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/history_viewmodel.dart'; // ✅ 이 경로가 정확해야 합니다!

class HistoryDetailScreen extends StatefulWidget {
  final String historyId;
  const HistoryDetailScreen({super.key, required this.historyId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends BaseScreen<HistoryDetailScreen> {
  late HistoryViewModel _viewModel;
  HistoryRecord? _record; // HistoryRecord 타입이 이제 history_viewmodel.dart에서 정의되므로 임포트 문제 해결

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _fetchRecordDetail();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelStateChanged);
    super.dispose();
  }

  void _onViewModelStateChanged() {
    showLoading(_viewModel.isLoading);
    if (mounted) {
      setState(() {
        _record = _viewModel.currentHistoryRecord;
      });
      if (!_viewModel.isLoading && _viewModel.errorMessage != null) {
        _showSnack(_viewModel.errorMessage!);
        _viewModel.clearErrorMessage();
      }
    }
  }

  Future<void> _fetchRecordDetail() async {
    await _viewModel.fetchHistoryRecordDetail(widget.historyId);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 내역 상세'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _record == null && _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _record == null
              ? const Center(child: Text('진단 내역을 불러올 수 없습니다.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '진단 날짜: ${_record!.date.toLocal().toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '요약: ${_record!.summary}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '상세 내용: ${_record!.detail}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '진단 이미지',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _record!.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
