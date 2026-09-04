-- ============================================
-- نظام الحضور والغياب
-- منصة أثر - الابتدائية 382
-- ============================================

-- حذف الجدول القديم إذا كان موجوداً
DROP TABLE IF EXISTS attendance CASCADE;

-- جدول الحضور والغياب (Attendance)
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- التاريخ
  attendance_date DATE NOT NULL,
  
  -- الحالة: حاضر (present) أو غائب (absent)
  status TEXT NOT NULL CHECK (status IN ('present', 'absent')),
  
  -- ملاحظات اختيارية
  notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- منع التكرار: طالبة واحدة في يوم واحد لها حالة واحدة فقط
  UNIQUE(student_id, attendance_date)
);

-- Indexes للأداء
CREATE INDEX idx_attendance_student ON attendance(student_id);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
CREATE INDEX idx_attendance_teacher ON attendance(teacher_id);
CREATE INDEX idx_attendance_status ON attendance(status);

-- Composite index لأداء أسرع
CREATE INDEX idx_attendance_student_date ON attendance(student_id, attendance_date);

-- تعطيل RLS مؤقتاً للاختبار
ALTER TABLE attendance DISABLE ROW LEVEL SECURITY;

-- ============================================
-- أمثلة على الاستخدام
-- ============================================

-- مثال: تسجيل حضور طالبة
-- INSERT INTO attendance (student_id, teacher_id, attendance_date, status)
-- VALUES ('student-uuid', 'teacher-uuid', '2024-09-04', 'present')
-- ON CONFLICT (student_id, attendance_date) 
-- DO UPDATE SET status = EXCLUDED.status, teacher_id = EXCLUDED.teacher_id, updated_at = NOW();

-- مثال: جلب حضور طالبة في شهر معين
-- SELECT * FROM attendance 
-- WHERE student_id = 'student-uuid' 
-- AND EXTRACT(YEAR FROM attendance_date) = 2024 
-- AND EXTRACT(MONTH FROM attendance_date) = 9
-- ORDER BY attendance_date;

-- مثال: إحصائيات شهر معين
-- SELECT 
--   COUNT(*) as total_days,
--   COUNT(*) FILTER (WHERE status = 'present') as present_days,
--   COUNT(*) FILTER (WHERE status = 'absent') as absent_days
-- FROM attendance
-- WHERE student_id = 'student-uuid'
-- AND EXTRACT(YEAR FROM attendance_date) = 2024
-- AND EXTRACT(MONTH FROM attendance_date) = 9;

-- ============================================
-- ملاحظات مهمة
-- ============================================

-- 1. UNIQUE(student_id, attendance_date) يمنع تسجيل مكرر
-- 2. ON CONFLICT يستخدم للتحديث بدلاً من الإضافة
-- 3. teacher_id يسجل آخر معلمة سجلت أو عدلت الحضور
-- 4. كل المعلمات يشوفون نفس البيانات (مشتركة)
