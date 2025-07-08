// C:\Users\user\Desktop\v4\backend\controllers\userController.js
// 사용자(마이페이지) 관련 비즈니스 로직을 처리합니다.

// 사용자 프로필 가져오기
exports.getUserProfile = async (req, res) => {
    const { id } = req.params;
    const pool = req.pool;

    // 요청을 보낸 사용자의 ID와 프로필을 요청하는 ID가 일치하는지 확인 (보안 강화)
    if (req.user.id !== parseInt(id)) {
        return res.status(403).json({ message: '다른 사용자의 프로필에 접근할 수 없습니다.' });
    }

    try {
        const [rows] = await pool.execute('SELECT id, username, email, created_at FROM users WHERE id = ?', [id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
        }
        res.status(200).json(rows[0]);
    } catch (error) {
        console.error('사용자 프로필 가져오기 오류:', error);
        res.status(500).json({ message: '사용자 프로필을 가져오는 데 실패했습니다.' });
    }
};

// 사용자 프로필 업데이트
exports.updateUserProfile = async (req, res) => {
    const { id } = req.params;
    const { username, email } = req.body; // 업데이트할 필드
    const pool = req.pool;

    if (req.user.id !== parseInt(id)) {
        return res.status(403).json({ message: '다른 사용자의 프로필을 업데이트할 수 없습니다.' });
    }

    if (!username && !email) {
        return res.status(400).json({ message: '업데이트할 필드를 입력해주세요.' });
    }

    try {
        let query = 'UPDATE users SET ';
        const params = [];
        const updates = [];

        if (username) {
            updates.push('username = ?');
            params.push(username);
        }
        if (email) {
            updates.push('email = ?');
            params.push(email);
        }

        query += updates.join(', ') + ' WHERE id = ?';
        params.push(id);

        const [result] = await pool.execute(query, params);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: '사용자를 찾을 수 없거나 업데이트할 내용이 없습니다.' });
        }
        res.status(200).json({ message: '프로필이 성공적으로 업데이트되었습니다.' });
    } catch (error) {
        console.error('사용자 프로필 업데이트 오류:', error);
        // 이메일 또는 사용자 이름 중복 오류 처리
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ message: '이미 존재하는 사용자 이름 또는 이메일입니다.' });
        }
        res.status(500).json({ message: '프로필 업데이트에 실패했습니다.' });
    }
};
