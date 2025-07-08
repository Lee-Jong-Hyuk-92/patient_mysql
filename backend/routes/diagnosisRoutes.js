// C:\Users\user\Desktop\v4\backend\routes\diagnosisRoutes.js
// 진단 관련 API 엔드포인트를 정의합니다.

const express = require('express');
const router = express.Router();
const diagnosisController = require('../controllers/diagnosisController');
const authMiddleware = require('../middleware/authMiddleware');

// 새 진단 기록 생성 (인증 필요)
router.post('/', authMiddleware.authenticateToken, diagnosisController.createDiagnosisRecord);

// 특정 진단 기록 가져오기 (인증 필요)
router.get('/:id', authMiddleware.authenticateToken, diagnosisController.getDiagnosisRecordById);

// 사용자별 진단 기록 가져오기 (인증 필요) - 예시
router.get('/user/:userId', authMiddleware.authenticateToken, diagnosisController.getDiagnosisRecordsByUserId);

module.exports = router;
