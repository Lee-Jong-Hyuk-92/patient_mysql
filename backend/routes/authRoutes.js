// C:\Users\user\Desktop\v4\backend\routes\authRoutes.js
// 인증 관련 API 엔드포인트를 정의합니다.

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController'); // 컨트롤러 모듈 가져오기

// 회원가입 라우트
router.post('/register', authController.registerUser);

// 로그인 라우트
router.post('/login', authController.loginUser);

// 아이디 중복 체크 라우트
router.get('/check-username', authController.checkUsernameAvailability);

module.exports = router;
