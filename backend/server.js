// C:\Users\user\Desktop\v4\backend\server.js
// 메인 서버 파일: 애플리케이션의 진입점 역할을 합니다.
// 모든 미들웨어, 데이터베이스 연결, 라우터 설정을 담당합니다.

const express = require('express');
const mysql = require('mysql2/promise'); // MySQL 데이터베이스 연결을 위한 promise 기반 드라이버
const bodyParser = require('body-parser'); // 요청 본문(body)을 파싱하기 위한 미들웨어
const cors = require('cors'); // 교차 출처 리소스 공유(CORS)를 허용하기 위한 미들웨어
require('dotenv').config(); // .env 파일에서 환경 변수를 로드합니다.

// 라우터 모듈을 가져옵니다.
// 이 파일들이 C:\Users\user\Desktop\v4\backend\routes\ 경로에 있는지 확인하세요.
const authRoutes = require('./routes/authRoutes');
const clinicRoutes = require('./routes/clinicRoutes');
const diagnosisRoutes = require('./routes/diagnosisRoutes');
const consultationRoutes = require('./routes/consultationRoutes');
const userRoutes = require('./routes/userRoutes'); // 마이페이지 관련

const app = express();
// 환경 변수에서 포트를 가져오거나 기본값 3000을 사용합니다.
const port = process.env.PORT || 3000;

// 미들웨어 설정
app.use(cors()); // 모든 출처에서의 요청을 허용 (개발 환경에서 편리하지만, 프로덕션에서는 특정 출처만 허용하도록 설정 권장)
app.use(bodyParser.json()); // JSON 형식의 요청 본문을 파싱하여 req.body 객체로 만듭니다.
app.use(bodyParser.urlencoded({ extended: true })); // URL-encoded 형식의 요청 본문을 파싱합니다.

// MySQL 연결 풀 설정
// 데이터베이스 연결 정보는 환경 변수에서 가져오는 것이 보안상 안전합니다.
// .env 파일에 DB_HOST, DB_USER, DB_PASSWORD, DB_NAME을 설정해주세요.
// 예시:
// DB_HOST=localhost
// DB_USER=root
// DB_PASSWORD=4907
// DB_NAME=user_db
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root', // 사용자님이 제공한 값으로 기본 설정
    password: process.env.DB_PASSWORD || '4907', // 사용자님이 제공한 값으로 기본 설정
    database: process.env.DB_NAME || 'user_db', // 사용자님이 제공한 값으로 기본 설정
    waitForConnections: true, // 연결을 사용할 수 있을 때까지 대기합니다.
    connectionLimit: 10, // 풀에 유지할 최대 연결 수
    queueLimit: 0 // 연결을 요청하는 대기열의 최대 수 (0 = 무제한)
});

// 데이터베이스 연결 테스트 미들웨어 (모든 요청에서 데이터베이스 풀에 접근할 수 있도록 req 객체에 추가)
app.use((req, res, next) => {
    req.pool = pool;
    next();
});

// API 라우터 설정
// 각 경로에 따라 해당 라우터 파일을 연결합니다.
app.use('/api/auth', authRoutes); // /api/auth 경로로 들어오는 요청은 authRoutes에서 처리
app.use('/api/clinics', clinicRoutes); // /api/clinics 경로로 들어오는 요청은 clinicRoutes에서 처리
app.use('/api/diagnosis', diagnosisRoutes); // /api/diagnosis 경로로 들어오는 요청은 diagnosisRoutes에서 처리
app.use('/api/consultations', consultationRoutes); // /api/consultations 경로로 들어오는 요청은 consultationRoutes에서 처리
app.use('/api/users', userRoutes); // /api/users 경로로 들어오는 요청은 userRoutes에서 처리

// 기본 경로 (루트) 핸들러
app.get('/', (req, res) => {
    res.send('Welcome to the Flutter Backend API!');
});

// 404 Not Found 핸들러
// 위에 정의된 어떤 라우트에도 일치하지 않는 요청을 처리합니다.
app.use((req, res, next) => {
    res.status(404).json({ message: 'API endpoint not found.' });
});

// 전역 오류 처리 미들웨어
// 모든 라우트 또는 미들웨어에서 발생한 예상치 못한 오류를 처리합니다.
app.use((err, req, res, next) => {
    console.error(err.stack); // 서버 콘솔에 오류 스택을 출력
    res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

// 서버 시작
// '0.0.0.0'을 추가하여 모든 네트워크 인터페이스에서 수신하도록 명시합니다.
// 이렇게 하면 로컬호스트뿐만 아니라, 다른 기기(예: 실제 스마트폰)에서도 IP 주소를 통해 접근할 수 있습니다.
app.listen(port, '0.0.0.0', () => {
    console.log(`Server running on http://localhost:${port}`);
    console.log(`Accessible via network IP: http://${require('os').networkInterfaces().Ethernet ? require('os').networkInterfaces().Ethernet[1].address : 'YOUR_IP_ADDRESS'}:${port}`);
    console.log('Press Ctrl+C to stop the server.');
});
