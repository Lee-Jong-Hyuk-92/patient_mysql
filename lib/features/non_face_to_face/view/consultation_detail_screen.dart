// C:\Users\user\Desktop\0703flutter_v2\lib\features\non_face_to_face\view\consultation_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/consultation_viewmodel.dart'; // ✅ 이 경로가 정확해야 합니다!

class ConsultationDetailScreen extends StatefulWidget {
  final String consultationId;
  const ConsultationDetailScreen({super.key, required this.consultationId});

  @override
  State<ConsultationDetailScreen> createState() => _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends BaseScreen<ConsultationDetailScreen> {
  late ConsultationViewModel _viewModel;
  Consultation? _consultation; // ✅ Consultation 타입이 이제 consultation_viewmodel.dart에서 정의되므로 임포트 문제 해결

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ConsultationViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _fetchConsultationDetail();
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
        _consultation = _viewModel.currentConsultation;
      });
      if (!_viewModel.isLoading && _viewModel.errorMessage != null) {
        _showSnack(_viewModel.errorMessage!);
        _viewModel.clearErrorMessage();
      }
    }
  }

  Future<void> _fetchConsultationDetail() async {
    await _viewModel.fetchConsultationDetail(widget.consultationId);
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
        title: const Text('비대면 진단 상세'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _consultation == null && _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consultation == null
              ? const Center(child: Text('비대면 진단 결과를 불러올 수 없습니다.'))
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
                                '요청일: ${_consultation!.requestDate.toLocal().toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '요약: ${_consultation!.summary}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'AI 예측 내용: ${_consultation!.aiPrediction}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Divider(height: 30),
                              Text(
                                '의사 진단 및 코멘트',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              _consultation!.doctorResponse != null
                                  ? Text(
                                      _consultation!.doctorResponse!,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    )
                                  : Text(
                                      '아직 의사 답변이 없습니다.',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '첨부 이미지',
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
                            _consultation!.imageUrl,
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
