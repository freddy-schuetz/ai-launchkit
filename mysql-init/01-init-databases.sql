-- Create databases for services
CREATE DATABASE IF NOT EXISTS leantime CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS easyappointments CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Ensure root has all privileges (should already have them, but for consistency)
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
