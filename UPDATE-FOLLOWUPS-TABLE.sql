-- ============================================
-- تحديث جدول student_followups لإضافة التقييمات
-- ============================================

-- إضافة حقول التقييمات
ALTER TABLE student_followups 
ADD COLUMN IF NOT EXISTS goal_1_evaluation TEXT CHECK (goal_1_evaluation IN ('mastered', 'partial', 'not_mastered')),
ADD COLUMN IF NOT EXISTS goal_2_evaluation TEXT CHECK (goal_2_evaluation IN ('mastered', 'partial', 'not_mastered')),
ADD COLUMN IF NOT EXISTS custom_goal_1_evaluation TEXT CHECK (custom_goal_1_evaluation IN ('mastered', 'partial', 'not_mastered')),
ADD COLUMN IF NOT EXISTS custom_goal_2_evaluation TEXT CHECK (custom_goal_2_evaluation IN ('mastered', 'partial', 'not_mastered'));
