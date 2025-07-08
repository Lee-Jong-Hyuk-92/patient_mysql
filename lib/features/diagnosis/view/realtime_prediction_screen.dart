//C:\Users\sptzk\Desktop\patient_mysql\lib\features\diagnosis\view\realtime_prediction_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/yolo.dart'; // ✅ 이 안에 Task enum 있음
import 'package:ultralytics_yolo/yolo_task.dart';
import 'package:ultralytics_yolo/yolo_result.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

class RealtimePredictionScreen extends StatefulWidget {
  const RealtimePredictionScreen({super.key});

  @override
  State<RealtimePredictionScreen> createState() => _RealtimePredictionScreenState();
}

class _RealtimePredictionScreenState extends State<RealtimePredictionScreen> {
  int _detectionCount = 0;
  double _currentFps = 0.0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  double _confidenceThreshold = 0.5;
  double _iouThreshold = 0.45;
  int _numItemsThreshold = 30;

  String? _modelPath;
  bool _isModelLoading = false;
  String _loadingMessage = '';
  double _currentZoomLevel = 1.0;

  final _yoloController = YOLOViewController();
  final _yoloViewKey = GlobalKey<YOLOViewState>();
  final bool _useController = true;

  @override
  void initState() {
    super.initState();
    _loadModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_useController) {
        _yoloController.setThresholds(
          confidenceThreshold: _confidenceThreshold,
          iouThreshold: _iouThreshold,
          numItemsThreshold: _numItemsThreshold,
        );
      } else {
        _yoloViewKey.currentState?.setThresholds(
          confidenceThreshold: _confidenceThreshold,
          iouThreshold: _iouThreshold,
          numItemsThreshold: _numItemsThreshold,
        );
      }
    });
  }

  Future<void> _loadModel() async {
    setState(() {
      _isModelLoading = true;
      _loadingMessage = '모델 로딩 중...';
    });

    try {
      const modelFileName = 'dental_best_float16.tflite';
      final ByteData data = await rootBundle.load('assets/models/$modelFileName');
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory modelDir = Directory('${appDir.path}/assets/models');

      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final File file = File('${modelDir.path}/$modelFileName');
      if (!await file.exists()) {
        await file.writeAsBytes(data.buffer.asUint8List());
      }

      setState(() {
        _modelPath = file.path;
        _isModelLoading = false;
      });
    } catch (e) {
      setState(() {
        _isModelLoading = false;
        _loadingMessage = '모델 로딩 실패: $e';
      });
    }
  }

  void _onDetectionResults(List<YOLOResult> results) {
    if (!mounted) return;

    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;

    if (elapsed >= 1000) {
      _currentFps = _frameCount * 1000 / elapsed;
      _frameCount = 0;
      _lastFpsUpdate = now;
    }

    setState(() {
      _detectionCount = results.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_modelPath != null && !_isModelLoading)
            YOLOView(
              key: const ValueKey('yolo_view'),
              controller: _yoloController,
              modelPath: _modelPath!,
              task: YOLOTask.segment, // 문자열로 명시
            )
          else if (_isModelLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_loadingMessage, style: const TextStyle(color: Colors.white)),
                ],
              ),
            )
          else
            const Center(child: Text('모델이 로드되지 않았습니다')),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DETECTIONS: $_detectionCount',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('FPS: ${_currentFps.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}