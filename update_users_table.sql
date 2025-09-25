-- Add approval_status column to users table
ALTER TABLE users ADD COLUMN approval_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending';

-- Update existing users to 'approved' if they already exist
UPDATE users SET approval_status = 'approved' WHERE approval_status IS NULL;
