// C:\Users\user\Desktop\v4\backend\controllers\consultationController.js
// 비대면 상담 관련 비즈니스 로직을 처리합니다.

// 새 상담 기록 생성
exports.createConsultationRecord = async (req, res) => {
    const { userId, consultationType, symptoms, consultationDetails, status } = req.body;
    const pool = req.pool;

    if (!userId || !consultationType || !symptoms || !consultationDetails) {
        return res.status(400).json({ message: '필수 필드를 모두 입력해주세요.' });
    }

    try {
        const [result] = await pool.execute(
            'INSERT INTO consultations (user_id, consultation_type, symptoms, consultation_details, status) VALUES (?, ?, ?, ?, ?)',
            [userId, consultationType, symptoms, consultationDetails, status || 'pending']
        );
        res.status(201).json({ message: '상담 기록이 성공적으로 생성되었습니다.', id: result.insertId });
    } catch (error) {
        console.error('상담 기록 생성 오류:', error);
        res.status(500).json({ message: '상담 기록 생성에 실패했습니다.' });
    }
};

// 특정 상담 기록 가져오기
exports.getConsultationRecordById = async (req, res) => {
    const { id } = req.params;
    const pool = req.pool;
    try {
        const [rows] = await pool.execute('SELECT * FROM consultations WHERE id = ?', [id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: '상담 기록을 찾을 수 없습니다.' });
        }
        res.status(200).json(rows[0]);
    } catch (error) {
        console.error('상담 기록 가져오기 오류:', error);
        res.status(500).json({ message: '상담 기록을 가져오는 데 실패했습니다.' });
    }
};

// 사용자별 상담 기록 가져오기
exports.getConsultationRecordsByUserId = async (req, res) => {
    const { userId } = req.params;
    const pool = req.pool;
    try {
        const [rows] = await pool.execute('SELECT * FROM consultations WHERE user_id = ? ORDER BY created_at DESC', [userId]);
        res.status(200).json(rows);
    } catch (error) {
        console.error('사용자별 상담 기록 가져오기 오류:', error);
        res.status(500).json({ message: '상담 기록을 가져오는 데 실패했습니다.' });
    }
};
