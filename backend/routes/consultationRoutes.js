// C:\Users\user\Desktop\v4\backend\routes\consultationRoutes.js
// 비대면 상담 관련 API 엔드포인트를 정의합니다.

const express = require('express');
const router = express.Router();
const consultationController = require('../controllers/consultationController');
const authMiddleware = require('../middleware/authMiddleware');

// 새 상담 기록 생성 (인증 필요)
router.post('/', authMiddleware.authenticateToken, consultationController.createConsultationRecord);

// 특정 상담 기록 가져오기 (인증 필요)
router.get('/:id', authMiddleware.authenticateToken, consultationController.getConsultationRecordById);

// 사용자별 상담 기록 가져오기 (인증 필요)
router.get('/user/:userId', authMiddleware.authenticateToken, consultationController.getConsultationRecordsByUserId);

module.exports = router;
