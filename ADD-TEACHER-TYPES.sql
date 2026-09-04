-- ============================================
-- إضافة أنواع المعلمات (نطق / تربية خاصة)
-- ============================================

-- إضافة حقل teacher_type للمعلمات
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS teacher_type TEXT CHECK (teacher_type IN ('speech_therapy', 'special_education'));

-- تحديث المعلمات الموجودة
-- أروى الفهد = معلمة نطق
UPDATE users 
SET teacher_type = 'speech_therapy' 
WHERE role = 'teacher' AND teacher_type IS NULL;

-- ملاحظة: يمكن للمديرة تغيير النوع من لوحة الإدارة
