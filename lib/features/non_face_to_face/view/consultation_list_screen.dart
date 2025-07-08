// C:\Users\user\Desktop\0703flutter_v2\lib\features\non_face_to_face\view\consultation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/consultation_viewmodel.dart'; // ✅ 이 경로가 정확해야 합니다!

class ConsultationListScreen extends StatefulWidget {
  const ConsultationListScreen({super.key});

  @override
  State<ConsultationListScreen> createState() => _ConsultationListScreenState();
}

class _ConsultationListScreenState extends BaseScreen<ConsultationListScreen> {
  late ConsultationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ConsultationViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _viewModel.fetchConsultations(); // 초기 데이터 로드
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
      }
    }
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
        title: const Text('비대면 진단 결과'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ConsultationViewModel>( // ✅ Consumer 타입 확인
        builder: (context, viewModel, child) {
          return viewModel.consultations.isEmpty && !viewModel.isLoading
              ? const Center(child: Text('비대면 진단 결과가 없습니다.'))
              : ListView.builder(
                  itemCount: viewModel.consultations.length,
                  itemBuilder: (context, index) {
                    final consultation = viewModel.consultations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: consultation.hasDoctorResponse ? Colors.green : Colors.orange,
                          child: Icon(
                            consultation.hasDoctorResponse ? Icons.check : Icons.hourglass_empty,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('진단 요청일: ${consultation.requestDate.toLocal().toString().split(' ')[0]}'),
                        subtitle: Text(consultation.summary),
                        trailing: consultation.hasDoctorResponse ? const Icon(Icons.arrow_forward_ios) : null,
                        onTap: consultation.hasDoctorResponse
                            ? () {
                                context.go('/consultations/detail/${consultation.id}');
                              }
                            : null, // 의사 응답 없으면 탭 비활성화
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
