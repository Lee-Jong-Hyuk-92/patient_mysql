// C:\Users\user\Desktop\v4\backend\routes\userRoutes.js
// 사용자(마이페이지) 관련 API 엔드포인트를 정의합니다.

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

// 특정 사용자 정보 가져오기 (인증 필요)
router.get('/:id', authMiddleware.authenticateToken, userController.getUserProfile);

// 사용자 프로필 업데이트 (인증 필요)
router.put('/:id', authMiddleware.authenticateToken, userController.updateUserProfile);

module.exports = router;
