// C:\Users\user\Desktop\v4\backend\routes\clinicRoutes.js
// 주변 클리닉 관련 API 엔드포인트를 정의합니다.

const express = require('express');
const router = express.Router();
const clinicController = require('../controllers/clinicController');
const authMiddleware = require('../middleware/authMiddleware'); // 인증 미들웨어 가져오기

// 모든 클리닉 정보 가져오기 (인증 필요)
router.get('/', authMiddleware.authenticateToken, clinicController.getAllClinics);

// 특정 클리닉 정보 가져오기 (인증 필요)
router.get('/:id', authMiddleware.authenticateToken, clinicController.getClinicById);

// 클리닉 예약 (인증 필요) - 예시로 POST 요청 추가
router.post('/:id/book', authMiddleware.authenticateToken, clinicController.bookClinicAppointment);

module.exports = router;
