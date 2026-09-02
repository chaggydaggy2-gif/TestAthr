-- ============================================
-- جداول الميزات الجديدة لمنصة أثر
-- ============================================

-- 1️⃣ جدول متابعة الطالبة (Student Follow-ups)
CREATE TABLE IF NOT EXISTS student_followups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- فترة المتابعة
  date_from DATE NOT NULL,
  date_to DATE NOT NULL,
  
  -- الأهداف من الخطة الفردية
  goal_1_id UUID REFERENCES plan_goals(id) ON DELETE SET NULL,
  goal_2_id UUID REFERENCES plan_goals(id) ON DELETE SET NULL,
  
  -- الأهداف اليدوية
  custom_goal_1 TEXT,
  custom_goal_1_type TEXT CHECK (custom_goal_1_type IN ('تمهيدي', 'استقبالي', 'تعبيري', 'نطق')),
  custom_goal_2 TEXT,
  custom_goal_2_type TEXT CHECK (custom_goal_2_type IN ('تمهيدي', 'استقبالي', 'تعبيري', 'نطق')),
  
  -- الوسائل المستخدمة (JSON array)
  tools JSONB DEFAULT '[]'::jsonb,
  
  -- ملاحظات
  notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index للبحث السريع
CREATE INDEX idx_followups_student ON student_followups(student_id);
CREATE INDEX idx_followups_teacher ON student_followups(teacher_id);
CREATE INDEX idx_followups_dates ON student_followups(date_from, date_to);


-- 2️⃣ جدول اختبار الذاكرة السمعية (Auditory Memory Tests)
CREATE TABLE IF NOT EXISTS auditory_memory_tests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- نوع النموذج (1 أو 2)
  test_type INTEGER NOT NULL CHECK (test_type IN (1, 2)),
  
  -- بيانات الاختبار (JSON)
  test_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- النتيجة
  score INTEGER,
  total_score INTEGER,
  
  -- ملاحظات
  notes TEXT,
  
  tested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index للبحث السريع
CREATE INDEX idx_memory_tests_student ON auditory_memory_tests(student_id);
CREATE INDEX idx_memory_tests_teacher ON auditory_memory_tests(teacher_id);
CREATE INDEX idx_memory_tests_type ON auditory_memory_tests(test_type);


-- 3️⃣ جدول التقرير المبدئي (Initial Reports)
CREATE TABLE IF NOT EXISTS initial_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- تاريخ التقرير
  report_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  -- المقدمة الثابتة (auto-filled)
  introduction TEXT DEFAULT 'بناءً على المتابعة المستمرة والملاحظات المباشرة للطالبة في بيئة التعلم، تم إعداد هذا التقرير المبدئي لتوثيق الأداء الحالي وتحديد نقاط القوة ومجالات التطوير.',
  
  -- محتوى التقرير (JSON sections)
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- حالة التقرير
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'final')),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index للبحث السريع
CREATE INDEX idx_reports_student ON initial_reports(student_id);
CREATE INDEX idx_reports_teacher ON initial_reports(teacher_id);
CREATE INDEX idx_reports_date ON initial_reports(report_date);
CREATE INDEX idx_reports_status ON initial_reports(status);


-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- تفعيل RLS على الجداول الجديدة
ALTER TABLE student_followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE auditory_memory_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE initial_reports ENABLE ROW LEVEL SECURITY;

-- سياسات الوصول لجدول متابعة الطالبة
CREATE POLICY "Teachers can view all followups" 
  ON student_followups FOR SELECT 
  USING (auth.role() = 'teacher' OR auth.role() = 'principal');

CREATE POLICY "Teachers can insert followups" 
  ON student_followups FOR INSERT 
  WITH CHECK (auth.role() = 'teacher' OR auth.role() = 'principal');

CREATE POLICY "Teachers can update their followups" 
  ON student_followups FOR UPDATE 
  USING (teacher_id = auth.uid() OR auth.role() = 'principal');

CREATE POLICY "Teachers can delete their followups" 
  ON student_followups FOR DELETE 
  USING (teacher_id = auth.uid() OR auth.role() = 'principal');

-- سياسات الوصول لاختبار الذاكرة السمعية
CREATE POLICY "Teachers can view all memory tests" 
  ON auditory_memory_tests FOR SELECT 
  USING (auth.role() = 'teacher' OR auth.role() = 'principal');

CREATE POLICY "Teachers can insert memory tests" 
  ON auditory_memory_tests FOR INSERT 
  WITH CHECK (auth.role() = 'teacher' OR auth.role() = 'principal');

CREATE POLICY "Teachers can update their memory tests" 
  ON auditory_memory_tests FOR UPDATE 
  USING (teacher_id = auth.uid() OR auth.role() = 'principal');

CREATE POLICY "Teachers can delete their memory tests" 
  ON auditory_memory_tests FOR DELETE 
  USING (teacher_id = auth.uid() OR auth.role() = 'principal');

-- سياسات الوصول لجدول التقارير المبدئية
CREATE POLICY "Teachers can view all reports" 
  ON initial_reports FOR SELECT 
  USING (auth.role() = 'teacher' OR auth.role() = 'principal');

CREATE POLICY "Teachers can insert reports" 
  ON initial_reports FOR INSERT 
  WITH CHECK (auth.role() = 'teacher' OR auth.role() = 'principal');

CREATE POLICY "Teachers can update their reports" 
  ON initial_reports FOR UPDATE 
  USING (teacher_id = auth.uid() OR auth.role() = 'principal');

CREATE POLICY "Teachers can delete their reports" 
  ON initial_reports FOR DELETE 
  USING (teacher_id = auth.uid() OR auth.role() = 'principal');


-- ============================================
-- دوال مساعدة
-- ============================================

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إضافة Triggers لتحديث updated_at
CREATE TRIGGER update_student_followups_updated_at
  BEFORE UPDATE ON student_followups
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_auditory_memory_tests_updated_at
  BEFORE UPDATE ON auditory_memory_tests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_initial_reports_updated_at
  BEFORE UPDATE ON initial_reports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- ملاحظات
-- ============================================

-- الوسائل المتاحة في tools (JSONB array example):
-- ["آيباد", "بطاقات مصورة", "فقاعات صابون", "أدوات تركيز وانتباه", "مجسمات", "أخرى"]

-- content في initial_reports (JSONB example):
-- {
--   "student_info": {"name": "...", "grade": "...", "date": "..."},
--   "introduction": "...",
--   "sections": [
--     {"title": "...", "content": "..."},
--     {"title": "...", "content": "..."}
--   ]
-- }

-- test_data في auditory_memory_tests (JSONB example):
-- {
--   "questions": [
--     {"question": "...", "answer": "...", "correct": true/false},
--     ...
--   ]
-- }
