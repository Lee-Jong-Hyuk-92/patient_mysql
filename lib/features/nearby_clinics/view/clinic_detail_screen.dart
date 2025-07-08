// C:\Users\user\Desktop\0703flutter_v2\lib\features\nearby_clinics\view\clinic_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/clinic_viewmodel.dart'; // 이 경로가 정확해야 합니다!

class ClinicDetailScreen extends StatefulWidget {
  final String clinicId;
  const ClinicDetailScreen({super.key, required this.clinicId});

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends BaseScreen<ClinicDetailScreen> {
  late ClinicViewModel _viewModel;
  Clinic? _clinic;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ClinicViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _fetchClinicDetail();
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
        _clinic = _viewModel.currentClinic;
      });
      if (!_viewModel.isLoading && _viewModel.errorMessage != null) {
        _showSnack(_viewModel.errorMessage!);
        _viewModel.clearErrorMessage();
      }
    }
  }

  Future<void> _fetchClinicDetail() async {
    await _viewModel.fetchClinicDetail(widget.clinicId);
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
        title: const Text('치과 상세 정보'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _clinic == null && _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clinic == null
              ? const Center(child: Text('치과 정보를 불러올 수 없습니다.'))
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
                                _clinic!.name,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text('주소: ${_clinic!.address}', style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(height: 5),
                              Text('전화: ${_clinic!.phone}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 5),
                              Text('진료 시간: ${_clinic!.openingHours}', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 5),
                              Text('평점: ${_clinic!.rating} / 5.0 (${_clinic!.reviewCount}개 후기)', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 10),
                              Image.network(
                                _clinic!.imageUrl,
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.local_hospital, size: 80, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 후기 열람 기능 (간단하게 스낵바로 표시)
                          _showSnack('후기 목록을 불러옵니다.');
                          // 실제로는 후기 목록 화면으로 이동하거나 모달 표시
                        },
                        icon: const Icon(Icons.reviews),
                        label: const Text('병원 후기 열람'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/clinics/book/${_clinic!.id}');
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('병원 예약하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
