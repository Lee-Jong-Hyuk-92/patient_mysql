// C:\Users\user\Desktop\v4\backend\controllers\diagnosisController.js
// 진단 관련 비즈니스 로직을 처리합니다.

// 새 진단 기록 생성
exports.createDiagnosisRecord = async (req, res) => {
    const { userId, symptoms, diagnosisResult, recommendedClinicId } = req.body;
    const pool = req.pool;

    if (!userId || !symptoms || !diagnosisResult) {
        return res.status(400).json({ message: '필수 필드를 모두 입력해주세요.' });
    }

    try {
        const [result] = await pool.execute(
            'INSERT INTO diagnosis_records (user_id, symptoms, diagnosis_result, recommended_clinic_id) VALUES (?, ?, ?, ?)',
            [userId, symptoms, diagnosisResult, recommendedClinicId]
        );
        res.status(201).json({ message: '진단 기록이 성공적으로 생성되었습니다.', id: result.insertId });
    } catch (error) {
        console.error('진단 기록 생성 오류:', error);
        res.status(500).json({ message: '진단 기록 생성에 실패했습니다.' });
    }
};

// 특정 진단 기록 가져오기
exports.getDiagnosisRecordById = async (req, res) => {
    const { id } = req.params;
    const pool = req.pool;
    try {
        const [rows] = await pool.execute('SELECT * FROM diagnosis_records WHERE id = ?', [id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: '진단 기록을 찾을 수 없습니다.' });
        }
        res.status(200).json(rows[0]);
    } catch (error) {
        console.error('진단 기록 가져오기 오류:', error);
        res.status(500).json({ message: '진단 기록을 가져오는 데 실패했습니다.' });
    }
};

// 사용자별 진단 기록 가져오기
exports.getDiagnosisRecordsByUserId = async (req, res) => {
    const { userId } = req.params;
    const pool = req.pool;
    try {
        const [rows] = await pool.execute('SELECT * FROM diagnosis_records WHERE user_id = ? ORDER BY created_at DESC', [userId]);
        res.status(200).json(rows);
    } catch (error) {
        console.error('사용자별 진단 기록 가져오기 오류:', error);
        res.status(500).json({ message: '진단 기록을 가져오는 데 실패했습니다.' });
    }
};
