// C:\Users\user\Desktop\v4\backend\controllers\clinicController.js
// 주변 클리닉 관련 비즈니스 로직을 처리합니다.

// 모든 클리닉 정보 가져오기
exports.getAllClinics = async (req, res) => {
    const pool = req.pool;
    try {
        const [rows] = await pool.query('SELECT * FROM clinics');
        res.status(200).json(rows);
    } catch (error) {
        console.error('클리닉 정보 가져오기 오류:', error);
        res.status(500).json({ message: '클리닉 정보를 가져오는 데 실패했습니다.' });
    }
};

// 특정 클리닉 정보 가져오기
exports.getClinicById = async (req, res) => {
    const { id } = req.params;
    const pool = req.pool;
    try {
        const [rows] = await pool.execute('SELECT * FROM clinics WHERE id = ?', [id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: '클리닉을 찾을 수 없습니다.' });
        }
        res.status(200).json(rows[0]);
    } catch (error) {
        console.error('특정 클리닉 정보 가져오기 오류:', error);
        res.status(500).json({ message: '클리닉 정보를 가져오는 데 실패했습니다.' });
    }
};

// 클리닉 예약 (예시)
exports.bookClinicAppointment = async (req, res) => {
    const { id } = req.params; // 클리닉 ID
    const { userId, appointmentDate, appointmentTime, notes } = req.body; // 사용자 ID, 예약 정보
    const pool = req.pool;

    if (!userId || !appointmentDate || !appointmentTime) {
        return res.status(400).json({ message: '예약에 필요한 모든 정보를 입력해주세요.' });
    }

    try {
        // 예약 정보를 데이터베이스에 저장하는 로직
        // 예시: appointments 테이블에 저장
        const [result] = await pool.execute(
            'INSERT INTO appointments (clinic_id, user_id, appointment_date, appointment_time, notes) VALUES (?, ?, ?, ?, ?)',
            [id, userId, appointmentDate, appointmentTime, notes]
        );
        res.status(201).json({ message: '클리닉 예약이 성공적으로 완료되었습니다.', appointmentId: result.insertId });
    } catch (error) {
        console.error('클리닉 예약 오류:', error);
        res.status(500).json({ message: '클리닉 예약에 실패했습니다.' });
    }
};
