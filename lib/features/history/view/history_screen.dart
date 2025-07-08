// C:\Users\user\Desktop\0703flutter_v2\lib\features\history\view\history_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/history_viewmodel.dart'; // ✅ 이 경로가 정확해야 합니다!

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends BaseScreen<HistoryScreen> {
  late HistoryViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _viewModel.fetchHistoryRecords(); // 초기 데이터 로드
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelStateChanged);
    _searchController.dispose();
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      // ✅ initialDate 대신 initialDateRange 사용 및 올바른 값 전달
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null && (picked.start != _startDate || picked.end != _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _viewModel.filterHistory(_searchController.text, _startDate, _endDate);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이전 진단 내역'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: '키워드 검색 (예: 충치, 잇몸)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            viewModel.filterHistory(_searchController.text, _startDate, _endDate);
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (value) {
                        viewModel.filterHistory(value, _startDate, _endDate);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDateRange(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate == null
                                  ? '날짜 필터링'
                                  : '${_startDate!.toLocal().toString().split(' ')[0]} ~ ${_endDate!.toLocal().toString().split(' ')[0]}',
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        if (_startDate != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                                viewModel.filterHistory(_searchController.text, null, null);
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: viewModel.filteredHistoryRecords.isEmpty && !viewModel.isLoading
                    ? const Center(child: Text('진단 내역이 없습니다.'))
                    : ListView.builder(
                        itemCount: viewModel.filteredHistoryRecords.length,
                        itemBuilder: (context, index) {
                          final record = viewModel.filteredHistoryRecords[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  record.thumbnailUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
                                ),
                              ),
                              title: Text('진단 날짜: ${record.date.toLocal().toString().split(' ')[0]}'),
                              subtitle: Text(record.summary),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context.go('/history/detail/${record.id}');
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
