// C:\Users\user\Desktop\0703flutter_v2\lib\features\nearby_clinics\view\clinic_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/clinic_viewmodel.dart'; // 이 경로가 정확해야 합니다!
import 'package:go_router/go_router.dart';

class ClinicBookingScreen extends StatefulWidget {
  final String clinicId;
  const ClinicBookingScreen({super.key, required this.clinicId});

  @override
  State<ClinicBookingScreen> createState() => _ClinicBookingScreenState();
}

class _ClinicBookingScreenState extends BaseScreen<ClinicBookingScreen> {
  late ClinicViewModel _viewModel;
  Clinic? _clinic;
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ClinicViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _fetchClinicDetail(); // 예약할 치과 정보 로드
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
      } else if (!_viewModel.isLoading && _viewModel.successMessage != null) {
        _showSnack(_viewModel.successMessage!);
        _viewModel.clearSuccessMessage();
        // 예약 성공 시 이전 화면으로 돌아가거나 예약 내역 화면으로 이동
        if (mounted) {
          context.pop(); // 예약 완료 후 이전 화면으로 돌아감
        }
      }
    }
  }

  Future<void> _fetchClinicDetail() async {
    await _viewModel.fetchClinicDetail(widget.clinicId);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)), // 3개월 후까지 예약 가능
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // 날짜 변경 시 시간 초기화
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _bookAppointment() {
    if (_clinic == null || _selectedDate == null || _selectedTime == null) {
      _showSnack('날짜와 시간을 선택해주세요.');
      return;
    }
    _viewModel.bookAppointment(
      clinicId: _clinic!.id,
      date: _selectedDate!,
      time: _selectedTime!,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('병원 예약하기'),
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '예약 날짜 선택',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? '날짜 선택'
                              : _selectedDate!.toLocal().toString().split(' ')[0],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '예약 시간 선택',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _selectedDate == null
                          ? const Text('날짜를 먼저 선택해주세요.', style: TextStyle(color: Colors.grey))
                          : Wrap(
                              spacing: 8.0,
                              children: _viewModel.getAvailableTimes(_selectedDate!).map((time) {
                                return ChoiceChip(
                                  label: Text(time),
                                  selected: _selectedTime == time,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedTime = selected ? time : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _bookAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('예약 확정하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
