// C:\Users\user\Desktop\v4\backend\controllers\authController.js

const bcrypt = require('bcryptjs'); // 비밀번호 해싱을 위해 필요
// const db = require('../config/db_connection'); // ✅ 이 줄은 제거되어야 합니다.

// 사용자 ID 중복 확인
exports.checkUsernameAvailability = async (req, res) => {
    const { username } = req.query; // 쿼리 파라미터에서 username 추출
    const pool = req.pool; // ✅ req.pool을 통해 데이터베이스 연결 풀에 접근합니다.

    // 디버그 로그 추가
    console.log(`[DEBUG] checkUsernameAvailability: Received username -> "${username}"`);

    if (!username) {
        console.log('[DEBUG] checkUsernameAvailability: Username is empty or null.');
        return res.status(400).json({ message: '사용자 이름을 입력해주세요.' });
    }

    try {
        const [rows] = await pool.execute( // ✅ pool.execute 사용
            'SELECT COUNT(*) AS count FROM users WHERE username = ?',
            [username]
        );

        const isAvailable = rows[0].count === 0; // count가 0이면 사용 가능

        // 디버그 로그 추가
        console.log(`[DEBUG] checkUsernameAvailability: Query result rows.length -> ${rows.length}`);
        console.log('[DEBUG] checkUsernameAvailability: Query result rows ->', rows);
        console.log(`[DEBUG] checkUsernameAvailability: Username "${username}" is ${isAvailable ? 'available' : 'not available'}.`);

        res.json({ available: isAvailable, message: isAvailable ? '사용 가능한 아이디입니다.' : '이미 사용 중인 아이디입니다.' });
    } catch (error) {
        console.error('사용자 이름 중복 확인 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};

// 사용자 회원가입
exports.registerUser = async (req, res) => {
    // ✅ 모든 필드를 요청 본문에서 추출합니다.
    const { username, password, email, name, gender, birth, phone } = req.body;
    const pool = req.pool; // ✅ req.pool을 통해 데이터베이스 연결 풀에 접근합니다.

    // 디버그 로그 추가
    console.log(`[DEBUG] registerUser: Received userData -> username: ${username}, email: ${email}, name: ${name}, gender: ${gender}, birth: ${birth}, phone: ${phone}`);

    // ✅ 필수 필드 유효성 검사를 업데이트합니다.
    if (!username || !password || !email || !name || !gender || !birth || !phone) {
        console.error('[DEBUG] registerUser: Missing required fields.');
        return res.status(400).json({ message: '모든 필수 필드를 입력해주세요.' });
    }

    try {
        // 비밀번호 해싱
        const hashedPassword = await bcrypt.hash(password, 10); // 솔트 라운드 10

        // 데이터베이스에 사용자 추가
        // ✅ INSERT 쿼리에 name, gender, birth, phone 컬럼을 추가하고, password_hash 대신 password를 사용합니다.
        const [result] = await pool.execute(
            'INSERT INTO users (username, password, email, name, gender, birth, phone) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [username, hashedPassword, email, name, gender, birth, phone]
        );

        console.log('회원가입 성공:', result);
        res.status(201).json({ message: '회원가입이 성공적으로 완료되었습니다.' });
    } catch (error) {
        // MySQL 에러 코드 확인 (예: ER_DUP_ENTRY for UNIQUE constraint violation)
        if (error.code === 'ER_DUP_ENTRY') {
            // 어떤 컬럼이 중복되었는지에 따라 더 구체적인 메시지 제공 가능
            if (error.sqlMessage.includes('username')) {
                console.error('회원가입 오류: 아이디 중복', error);
                return res.status(409).json({ message: '이미 사용 중인 아이디입니다.' });
            } else if (error.sqlMessage.includes('email')) {
                console.error('회원가입 오류: 이메일 중복', error);
                return res.status(409).json({ message: '이미 사용 중인 이메일입니다.' });
            }
            console.error('회원가입 오류: 기타 중복 데이터', error);
            return res.status(409).json({ message: '이미 사용 중인 데이터가 있습니다.' });
        }
        console.error('회원가입 오류:', error); // 일반적인 서버 오류 로깅
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};

// 사용자 로그인
exports.loginUser = async (req, res) => {
    const { username, password } = req.body;
    const pool = req.pool; // ✅ req.pool을 통해 데이터베이스 연결 풀에 접근합니다.

    if (!username || !password) {
        return res.status(400).json({ message: '사용자 이름과 비밀번호를 입력해주세요.' });
    }

    try {
        const [rows] = await pool.execute( // ✅ pool.execute 사용
            'SELECT * FROM users WHERE username = ?',
            [username]
        );

        if (rows.length === 0) {
            return res.status(401).json({ message: '아이디 또는 비밀번호가 올바르지 않습니다.' });
        }

        const user = rows[0];
        const isMatch = await bcrypt.compare(password, user.password); // 저장된 해시 비밀번호와 비교

        if (!isMatch) {
            return res.status(401).json({ message: '아이디 또는 비밀번호가 올바르지 않습니다.' });
        }

        // JWT 토큰 생성 (필요하다면)
        const jwt = require('jsonwebtoken'); // jwt 모듈이 이 스코프에 없으므로 다시 require
        const token = jwt.sign(
            { id: user.id, username: user.username },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.status(200).json({ message: '로그인 성공!', token, userId: user.id, username: user.username });
    } catch (error) {
        console.error('로그인 오류:', error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
};
