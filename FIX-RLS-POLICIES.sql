-- ============================================
-- إصلاح سياسات RLS للجداول الجديدة
-- ============================================

-- حذف السياسات القديمة
DROP POLICY IF EXISTS "Teachers can view all followups" ON student_followups;
DROP POLICY IF EXISTS "Teachers can insert followups" ON student_followups;
DROP POLICY IF EXISTS "Teachers can update their followups" ON student_followups;
DROP POLICY IF EXISTS "Teachers can delete their followups" ON student_followups;

DROP POLICY IF EXISTS "Teachers can view all memory tests" ON auditory_memory_tests;
DROP POLICY IF EXISTS "Teachers can insert memory tests" ON auditory_memory_tests;
DROP POLICY IF EXISTS "Teachers can update their memory tests" ON auditory_memory_tests;
DROP POLICY IF EXISTS "Teachers can delete their memory tests" ON auditory_memory_tests;

DROP POLICY IF EXISTS "Teachers can view all reports" ON initial_reports;
DROP POLICY IF EXISTS "Teachers can insert reports" ON initial_reports;
DROP POLICY IF EXISTS "Teachers can update their reports" ON initial_reports;
DROP POLICY IF EXISTS "Teachers can delete their reports" ON initial_reports;


-- ============================================
-- سياسات جديدة مبسطة (allow all for now)
-- ============================================

-- متابعة الطالبة
CREATE POLICY "Enable all access for authenticated users"
  ON student_followups
  FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- اختبار الذاكرة السمعية
CREATE POLICY "Enable all access for authenticated users"
  ON auditory_memory_tests
  FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- التقرير المبدئي
CREATE POLICY "Enable all access for authenticated users"
  ON initial_reports
  FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);
