초보자를 위한 MySQL 데이터베이스 처음부터 설정 가이드
이 가이드는 Flutter 앱 백엔드에서 사용할 MySQL 데이터베이스를 처음부터 설정하는 방법을 안내합니다. 데이터베이스 생성, 사용자 계정 설정, 필요한 테이블 생성 및 샘플 데이터 삽입 과정을 포함합니다.

1단계: MySQL 서버 접속하기
먼저 MySQL 서버에 접속해야 합니다. 일반적으로 터미널(Windows의 경우 명령 프롬프트 또는 PowerShell, macOS/Linux의 경우 터미널)을 사용합니다.

터미널 열기:

Windows: Win + R을 누르고 cmd를 입력한 후 Enter.

macOS/Linux: Applications -> Utilities -> Terminal 또는 Ctrl + Alt + T.

MySQL 접속 명령어 입력:
MySQL이 설치된 경로에 따라 명령어가 약간 다를 수 있습니다. 일반적으로 다음 명령어를 사용합니다.

mysql -u root -p

-u root: root 사용자(관리자 계정)로 접속하겠다는 의미입니다.

-p: 비밀번호를 입력하라는 프롬프트가 나타납니다.

비밀번호 입력:
Enter password: 프롬프트가 나타나면 MySQL 설치 시 설정했던 root 비밀번호를 입력하고 Enter를 누릅니다. 비밀번호를 입력해도 화면에는 아무것도 표시되지 않으니 당황하지 마세요.

성공적으로 접속하면 다음과 유사한 메시지가 나타납니다.

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is X
Server version: 8.0.XX MySQL Community Server - GPL

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

이제 mysql> 프롬프트가 보이면 MySQL 명령어를 입력할 준비가 된 것입니다.

2단계: 데이터베이스 생성 및 사용자 설정
Flutter 앱에서 사용할 데이터베이스(user_db)를 생성하고, 이 데이터베이스에 접근할 수 있는 전용 사용자(t0703_user)를 설정합니다.

user_db 데이터베이스 생성:
이 데이터베이스는 사용자 정보, 진단 기록, 치과 정보 등 앱의 모든 데이터를 저장할 것입니다.

CREATE DATABASE user_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CHARACTER SET utf8mb4: 한글, 이모지 등 다양한 문자를 지원하기 위한 설정입니다.

COLLATE utf8mb4_unicode_ci: 대소문자 구분을 하지 않는 정렬 방식입니다.

t0703_user 사용자 생성 및 권한 부여:
이 사용자는 Flutter 앱 백엔드에서 데이터베이스에 연결할 때 사용될 것입니다. your_strong_password를 반드시 강력하고 안전한 비밀번호로 변경하세요.

CREATE USER 't0703_user'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON user_db.* TO 't0703_user'@'localhost';
FLUSH PRIVILEGES;

't0703_user'@'localhost': t0703_user라는 사용자가 localhost(현재 MySQL 서버가 실행 중인 컴퓨터)에서만 접속할 수 있도록 허용합니다.

GRANT ALL PRIVILEGES ON user_db.*: user_db 데이터베이스의 모든 테이블에 대한 모든 권한을 부여합니다.

FLUSH PRIVILEGES;: 변경된 권한 설정을 즉시 적용합니다.

💡 원격 접속이 필요한 경우 (예: 다른 컴퓨터에서 백엔드 실행 시):
't0703_user'@'localhost' 대신 't0703_user'@'%'를 사용하면 모든 IP 주소에서 접속을 허용합니다. 하지만 이는 보안상 매우 취약하므로, 특정 IP 주소(예: 't0703_user'@'192.168.1.100')를 지정하거나 방화벽 설정을 강화하는 것을 강력히 권장합니다.

3단계: 테이블 생성
이제 user_db 데이터베이스 안에 앱에 필요한 테이블들을 생성합니다. 먼저 user_db를 사용하겠다고 선언해야 합니다.

user_db 데이터베이스 사용 선언:

USE user_db;

users 테이블 생성:
사용자 정보(아이디, 비밀번호 해시, 이메일, 이름, 성별, 생년월일, 전화번호 등)를 저장합니다.

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    gender CHAR(1) NOT NULL,
    birth VARCHAR(10) NOT NULL,
    password VARCHAR(255) NOT NULL, -- 실제 앱에서는 password_hash로 변경하여 해시된 비밀번호를 저장해야 합니다.
    phone VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    status ENUM('active','inactive','deleted') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

중요: password 컬럼은 실제 프로덕션 환경에서는 password_hash와 같이 비밀번호의 해시값을 저장해야 합니다. 백엔드 코드에서 bcrypt를 사용하여 비밀번호를 해싱하고 저장하도록 구현되어 있습니다.

clinics 테이블 생성:
치과 정보(이름, 주소, 전화번호, 설명 등)를 저장합니다.

CREATE TABLE clinics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

diagnosis_records 테이블 생성:
사용자의 진단 기록(증상, 진단 결과, 이미지 경로, 모델 추론 JSON 등)을 저장합니다.

CREATE TABLE diagnosis_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    symptoms TEXT NOT NULL,
    image_path VARCHAR(512) NULL, -- 사진 파일의 경로 또는 URL (NULL 허용)
    diagnosis_result TEXT,
    inference_result_json JSON NULL, -- 모델 추론 결과 JSON (NULL 허용, MySQL 5.7+ 필요)
    recommended_clinic_id INT, -- 추천 치과 ID (NULL 허용)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE: users 테이블의 id와 연결되며, 사용자가 삭제되면 관련 진단 기록도 함께 삭제됩니다.

appointments 테이블 생성:
사용자와 치과 간의 예약 정보를 저장합니다.

CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clinic_id INT NOT NULL,
    appointment_date DATE NOT NULL, -- 예약 날짜 (YYYY-MM-DD)
    appointment_time VARCHAR(10) NOT NULL, -- 예약 시간 (HH:MM)
    notes TEXT, -- 예약 시 추가 메모
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending', -- 예약 상태
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
);

4단계: 샘플 데이터 삽입 (선택 사항)
테이블이 올바르게 작동하는지 확인하고 앱 개발을 위해 몇 가지 샘플 데이터를 삽입할 수 있습니다.

-- `users` 테이블에 샘플 사용자 데이터 삽입
-- 비밀번호는 실제 백엔드에서 해싱하여 저장되므로, 여기서는 임시로 'hashed_password_X'와 같이 표시합니다.
-- 실제 회원가입 시에는 앱에서 입력된 비밀번호가 백엔드에서 해싱되어 저장됩니다.
INSERT INTO users (username, email, gender, birth, password, phone, name) VALUES
('1111', 'temp_email_1751872052771@example.com', 'M', '1975-11-11', '$2b$10$uSWwHtwq6AA80XbQVswYxeU9Mi9.aY7SGux3ymrI/9h.Avk9oyBoG', '11111111111', '환경'),
('2222', 'temp_email_1751873196292@example.com', 'M', '1970-11-11', '$2b$10$D7YCjtDYaYL2MXQrZcjkMO30t59/DDNlHMAQq5z3Chn.0oHJa0vAC', '22222222222', '무엇'),
('3333', 'temp_email_1751873504977@example.com', 'F', '1987-11-11', '$2b$10$bDruxTCiti1wngX3vU9k6uoZIRTEEmBixH3/n7cedvMQ2HEx8wiQy', '33333333333', '설레다');

-- `clinics` 테이블에 샘플 치과 데이터 삽입
INSERT INTO clinics (name, address, phone, description) VALUES
('서울 미소 치과', '서울시 강남구 테헤란로 123', '02-1234-5678', '친절한 진료와 최신 설비를 갖춘 치과입니다.'),
('부산 해운대 치과', '부산시 해운대구 바닷가로 45', '051-987-6543', '바다가 보이는 편안한 치과입니다.');

-- `diagnosis_records` 테이블에 샘플 진단 기록 삽입
-- image_path와 inference_result_json은 앱에서 진단 시 저장됩니다.
INSERT INTO diagnosis_records (user_id, symptoms, image_path, diagnosis_result, inference_result_json, recommended_clinic_id) VALUES
(2, '잇몸이 붓고 피가 납니다.', '/path/to/image/gum_inflammation.jpg', '잇몸 염증 초기 단계로 보입니다.', '{"disease": "gingivitis", "confidence": 0.85}', 1),
(3, '어금니가 시리고 아픕니다.', '/path/to/image/tooth_decay.jpg', '충치 가능성이 있습니다. 치과 방문이 필요합니다.', '{"disease": "cavity", "confidence": 0.92}', 2);

-- `appointments` 테이블에 샘플 예약 데이터 삽입
INSERT INTO appointments (user_id, clinic_id, appointment_date, appointment_time, notes, status) VALUES
(2, 1, '2025-07-10', '10:00', '잇몸 검진', 'confirmed'),
(3, 2, '2025-07-15', '14:30', '정기 스케일링', 'pending');

5단계: 데이터베이스 구조 및 데이터 확인
모든 테이블이 잘 생성되고 데이터가 삽입되었는지 확인합니다.

모든 데이터베이스 목록 확인:

SHOW DATABASES;
```user_db`가 목록에 있는지 확인합니다.


user_db 데이터베이스 사용 선언:

USE user_db;

테이블 목록 확인:

SHOW TABLES;
```users`, `clinics`, `diagnosis_records`, `appointments` 테이블이 목록에 있는지 확인합니다.


각 테이블의 구조 확인:

DESCRIBE users;
DESCRIBE clinics;
DESCRIBE diagnosis_records;
DESCRIBE appointments;

각 테이블의 컬럼들이 위에서 정의한 대로 생성되었는지 확인합니다.

각 테이블의 데이터 확인:

SELECT * FROM users;
SELECT * FROM clinics;
SELECT * FROM diagnosis_records;
SELECT * FROM appointments;

삽입한 샘플 데이터가 올바르게 표시되는지 확인합니다.

6단계: MySQL 서버 재시작 (필요시)
데이터베이스 스키마를 변경하거나 새로운 사용자를 추가한 후에는 MySQL 서버를 재시작하여 변경 사항이 완전히 적용되도록 하는 것이 좋습니다.

Linux: sudo systemctl restart mysql 또는 sudo service mysql restart

Windows: 서비스 관리자에서 MySQL 서비스를 찾아 재시작합니다.

이제 MySQL 데이터베이스가 Flutter 앱 백엔드와 연동될 준비가 완료되었습니다!
