// C:\Users\user\Desktop\v4\backend\middleware\authMiddleware.js
// 인증 미들웨어: JWT 토큰을 검증하여 보호된 라우트에 대한 접근을 제어합니다.

const jwt = require('jsonwebtoken');

exports.authenticateToken = (req, res, next) => {
    // 요청 헤더에서 Authorization 값을 가져옵니다. (예: Bearer <token>)
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // 'Bearer ' 부분을 제거하고 토큰만 추출

    if (token == null) {
        return res.status(401).json({ message: '인증 토큰이 필요합니다.' }); // 토큰이 없는 경우 401 Unauthorized 응답
    }

    // 토큰 검증
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            console.error('토큰 검증 오류:', err);
            return res.status(403).json({ message: '유효하지 않거나 만료된 토큰입니다.' }); // 토큰이 유효하지 않은 경우 403 Forbidden 응답
        }
        req.user = user; // 검증된 사용자 정보를 req.user에 저장하여 다음 미들웨어 또는 컨트롤러에서 사용할 수 있도록 합니다.
        next(); // 다음 미들웨어 또는 라우트 핸들러로 제어를 넘깁니다.
    });
};
