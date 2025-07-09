import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/base_screen.dart';
import '../viewmodel/diagnosis_viewmodel.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic>? result; // ✅ 외부에서 result를 받을 수 있도록 추가

  const ResultScreen({super.key, this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends BaseScreen<ResultScreen> {
  late DiagnosisViewModel _viewModel;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<DiagnosisViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);

    if (widget.result != null) {
      // ✅ 전달된 result가 있으면 수동으로 결과 설정
      _viewModel.setDiagnosisResult(widget.result!);
    } else {
      // ✅ 없으면 기존 방식대로 fetch
      _viewModel.fetchDiagnosisResult();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelStateChanged);
    super.dispose();
  }

  void _onViewModelStateChanged() {
    showLoading(_viewModel.isLoading);

    if (mounted) {
      setState(() {});
      if (!_viewModel.isLoading && _viewModel.errorMessage != null) {
        _showSnack(_viewModel.errorMessage!);
        _viewModel.clearErrorMessage();
      } else if (!_viewModel.isLoading && _viewModel.successMessage != null) {
        _showSnack(_viewModel.successMessage!);
        _viewModel.clearSuccessMessage();
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Consumer<DiagnosisViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('진단 결과'),
            centerTitle: true,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/upload');
              },
            ),
          ),
          body: SingleChildScrollView(
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
                          '진단 요약',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          viewModel.diagnosisResult?.summary ?? '진단 결과 요약 준비 중...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('병변 오버레이 보기', style: Theme.of(context).textTheme.bodyMedium),
                            Switch(
                              value: _showOverlay,
                              onChanged: (value) {
                                setState(() => _showOverlay = value);
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 진단 이미지
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          viewModel.diagnosisResult?.originalImageUrl ??
                              'https://placehold.co/300x200/png?text=Original+Image',
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
                        if (_showOverlay && viewModel.diagnosisResult?.overlayImageUrl != null)
                          Image.network(
                            viewModel.diagnosisResult!.overlayImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.transparent,
                              child: const Center(
                                child: Text('오버레이 이미지 로드 실패', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildActionButton(
                  context: context,
                  text: '진단 결과 이미지 저장',
                  onPressed: () => viewModel.saveImage(viewModel.diagnosisResult?.overlayImageUrl ?? ''),
                  icon: Icons.download,
                  isLoading: viewModel.isLoading,
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  context: context,
                  text: '원본 이미지 저장',
                  onPressed: () => viewModel.saveImage(viewModel.diagnosisResult?.originalImageUrl ?? ''),
                  icon: Icons.image,
                  isLoading: viewModel.isLoading,
                ),
                const SizedBox(height: 30),

                _buildActionButton(
                  context: context,
                  text: 'AI 예측 기반 비대면 진단 신청',
                  onPressed: () => viewModel.requestNonFaceToFaceDiagnosis(),
                  icon: Icons.medical_services,
                  isPrimary: true,
                  isLoading: viewModel.isLoading,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isPrimary = false,
    required bool isLoading,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
        foregroundColor: isPrimary ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
