// C:\Users\user\Desktop\0703flutter_v2\lib\features\nearby_clinics\view\clinic_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/base_screen.dart';
import '../viewmodel/clinic_viewmodel.dart'; // 이 경로가 정확해야 합니다!

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends BaseScreen<ClinicListScreen> {
  late ClinicViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortOption = 'distance'; // 'distance' 또는 'popularity'

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ClinicViewModel>(context, listen: false);
    _viewModel.addListener(_onViewModelStateChanged);
    _viewModel.fetchClinics(); // 초기 데이터 로드
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

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 치과'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ClinicViewModel>(
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
                        labelText: '치과 이름 또는 특징 검색',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            viewModel.filterAndSortClinics(_searchController.text, _selectedSortOption);
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (value) {
                        viewModel.filterAndSortClinics(value, _selectedSortOption);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ChoiceChip(
                          label: const Text('거리순'),
                          selected: _selectedSortOption == 'distance',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSortOption = 'distance';
                              });
                              viewModel.filterAndSortClinics(_searchController.text, _selectedSortOption);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('인기순'),
                          selected: _selectedSortOption == 'popularity',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSortOption = 'popularity';
                              });
                              viewModel.filterAndSortClinics(_searchController.text, _selectedSortOption);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: viewModel.filteredClinics.isEmpty && !viewModel.isLoading
                    ? const Center(child: Text('주변 치과를 찾을 수 없습니다.'))
                    : ListView.builder(
                        itemCount: viewModel.filteredClinics.length,
                        itemBuilder: (context, index) {
                          final clinic = viewModel.filteredClinics[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  clinic.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_hospital, size: 60),
                                ),
                              ),
                              title: Text(clinic.name),
                              subtitle: Text('${clinic.address} (${clinic.distance.toStringAsFixed(1)}km)'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context.go('/clinics/detail/${clinic.id}');
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
