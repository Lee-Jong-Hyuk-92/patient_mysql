        // C:\Users\user\Desktop\0703flutter_v2\lib\features\diagnosis\view\result_screen.dart

        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';
        import 'package:provider/provider.dart';
        import '../../../core/base_screen.dart';
        import '../viewmodel/diagnosis_viewmodel.dart'; // 이 경로가 정확해야 합니다!

        class ResultScreen extends StatefulWidget {
          const ResultScreen({super.key});

          @override
          State<ResultScreen> createState() => _ResultScreenState();
        }

        class _ResultScreenState extends BaseScreen<ResultScreen> {
          late DiagnosisViewModel _viewModel;
          bool _showOverlay = true; // 병변 오버레이 표시 여부

          @override
          void initState() {
            super.initState();
            // DiagnosisViewModel을 Provider를 통해 가져오기
            // listen: false로 설정하여 initState에서만 접근하고, 이후 변화는 addListener로 처리
            _viewModel = Provider.of<DiagnosisViewModel>(context, listen: false);
            // ViewModel의 상태 변화를 감지하여 UI 업데이트
            _viewModel.addListener(_onViewModelStateChanged);
            // 화면 진입 시 진단 결과 데이터 로드
            _viewModel.fetchDiagnosisResult();
          }

          @override
          void dispose() {
            _viewModel.removeListener(_onViewModelStateChanged);
            super.dispose();
          }

          void _onViewModelStateChanged() {
            // ViewModel의 로딩 상태에 따라 BaseScreen의 showLoading 호출
            showLoading(_viewModel.isLoading);

            if (mounted) {
              // 위젯이 마운트된 상태에서만 setState 호출
              setState(() {
                // 로딩 상태 변경 또는 에러 메시지 업데이트 시 UI 갱신
              });

              if (!_viewModel.isLoading && _viewModel.errorMessage != null) {
                // 에러 메시지 표시
                _showSnack(_viewModel.errorMessage!);
                _viewModel.clearErrorMessage(); // 메시지 표시 후 초기화
              } else if (!_viewModel.isLoading && _viewModel.successMessage != null) {
                // 성공 메시지 표시
                _showSnack(_viewModel.successMessage!);
                _viewModel.clearSuccessMessage(); // 메시지 표시 후 초기화
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
            // Consumer를 사용하여 ViewModel의 변화에 따라 UI 자동 업데이트
            return Consumer<DiagnosisViewModel>(
              builder: (context, viewModel, child) {
                // _viewModel 대신 viewModel 사용
                // _viewModel = viewModel; // Consumer의 viewModel을 _viewModel에 할당하여 다른 메서드에서 사용 가능하게 함 (선택 사항)

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('진단 결과'),
                    centerTitle: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // 진단 결과 화면에서 '사진으로 예측하기' 화면으로 직접 이동
                        context.go('/upload');
                      },
                    ),
                  ),
                  body: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능하게
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 진단 요약
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
                                    Text(
                                      '병변 오버레이 보기',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Switch(
                                      value: _showOverlay,
                                      onChanged: (value) {
                                        setState(() {
                                          _showOverlay = value;
                                        });
                                      },
                                      activeColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 진단 이미지 및 오버레이
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
                                // 원본 이미지
                                Image.network(
                                  viewModel.diagnosisResult?.originalImageUrl ?? 'https://placehold.co/300x200/png?text=Original+Image',
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
                                // 병변 오버레이 (조건부 표시)
                                if (_showOverlay && viewModel.diagnosisResult?.overlayImageUrl != null)
                                  Image.network(
                                    viewModel.diagnosisResult!.overlayImageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 250,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: double.infinity,
                                      height: 250,
                                      color: Colors.transparent, // 투명하게 유지
                                      child: const Center(child: Text('오버레이 이미지 로드 실패', style: TextStyle(color: Colors.red))),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 예측 결과 및 원본 이미지 저장 버튼
                        _buildActionButton(
                          context: context,
                          text: '진단 결과 이미지 저장',
                          onPressed: () => viewModel.saveImage(viewModel.diagnosisResult?.overlayImageUrl ?? ''),
                          icon: Icons.download,
                          isLoading: viewModel.isLoading, // 로딩 상태 전달
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          context: context,
                          text: '원본 이미지 저장',
                          onPressed: () => viewModel.saveImage(viewModel.diagnosisResult?.originalImageUrl ?? ''),
                          icon: Icons.image,
                          isLoading: viewModel.isLoading, // 로딩 상태 전달
                        ),
                        const SizedBox(height: 30),

                        // AI 예측 기반 비대면 진단 신청 버튼
                        _buildActionButton(
                          context: context,
                          text: 'AI 예측 기반 비대면 진단 신청',
                          onPressed: () => viewModel.requestNonFaceToFaceDiagnosis(),
                          icon: Icons.medical_services,
                          isPrimary: true, // 강조 색상 적용
                          isLoading: viewModel.isLoading, // 로딩 상태 전달
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // 공통 버튼 위젯 (isLoading 매개변수 추가)
          Widget _buildActionButton({
            required BuildContext context,
            required String text,
            required VoidCallback onPressed,
            required IconData icon,
            bool isPrimary = false,
            required bool isLoading, // isLoading 매개변수 추가
          }) {
            return ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed, // 로딩 중에는 버튼 비활성화
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
        