-- ============================================
-- جداول معلمات التربية الخاصة
-- منصة أثر - الابتدائية 382
-- ============================================

-- 1️⃣ جدول موافقة ولي الأمر (Parent Consent)
CREATE TABLE IF NOT EXISTS parent_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- بنود الموافقة
  consent_given BOOLEAN DEFAULT false,
  consent_date DATE,
  parent_signature TEXT,
  
  -- بنود النموذج (JSON)
  consent_items JSONB DEFAULT '[]'::jsonb,
  
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_consents_student ON parent_consents(student_id);
CREATE INDEX idx_consents_teacher ON parent_consents(teacher_id);


-- 2️⃣ جدول ملاحظات الطالبة (Student Notes)
CREATE TABLE IF NOT EXISTS student_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  note_date DATE NOT NULL,
  note_type TEXT NOT NULL,
  note_content TEXT NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notes_student ON student_notes(student_id);
CREATE INDEX idx_notes_teacher ON student_notes(teacher_id);
CREATE INDEX idx_notes_date ON student_notes(note_date);


-- 3️⃣ جدول البيانات الأولية (Initial Data)
CREATE TABLE IF NOT EXISTS initial_student_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- بيانات ثابتة (JSONB لمرونة البنود)
  data_fields JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  completed BOOLEAN DEFAULT false,
  completed_date DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_initial_data_student ON initial_student_data(student_id);
CREATE INDEX idx_initial_data_teacher ON initial_student_data(teacher_id);


-- 4️⃣ جدول الخطة الفردية IEP (Individual Education Plan)
CREATE TABLE IF NOT EXISTS iep_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- بيانات الطالبة
  student_info JSONB DEFAULT '{}'::jsonb,
  
  -- المستوى الحالي
  current_level TEXT,
  
  -- نقاط القوة والاحتياج
  strengths TEXT,
  needs TEXT,
  
  -- الأهداف (JSON arrays)
  semester_goals JSONB DEFAULT '[]'::jsonb,
  short_term_goals JSONB DEFAULT '[]'::jsonb,
  behavioral_goals JSONB DEFAULT '[]'::jsonb,
  
  -- الوسائل والأدوات
  tools_materials JSONB DEFAULT '[]'::jsonb,
  
  -- استراتيجيات التدريس
  teaching_strategies JSONB DEFAULT '[]'::jsonb,
  
  -- التواريخ
  start_date DATE,
  end_date DATE,
  
  -- حالة الهدف
  status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'achieved')),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_iep_student ON iep_plans(student_id);
CREATE INDEX idx_iep_teacher ON iep_plans(teacher_id);
CREATE INDEX idx_iep_status ON iep_plans(status);


-- 5️⃣ جدول متابعة الجلسات (Session Tracking)
CREATE TABLE IF NOT EXISTS session_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  iep_plan_id UUID REFERENCES iep_plans(id) ON DELETE SET NULL,
  
  -- فترة الجلسة
  session_date_from DATE NOT NULL,
  session_date_to DATE NOT NULL,
  
  -- الهدف قصير المدى (from IEP)
  short_term_goal_id TEXT,
  short_term_goal_text TEXT,
  
  -- الأهداف الإجرائية السلوكية
  behavioral_objectives JSONB DEFAULT '[]'::jsonb,
  
  -- تقييم كل هدف
  evaluations JSONB DEFAULT '[]'::jsonb,
  
  -- الوسائل المستخدمة
  tools_used JSONB DEFAULT '[]'::jsonb,
  
  -- أساليب التدريس
  teaching_methods JSONB DEFAULT '[]'::jsonb,
  
  -- أساليب التعزيز
  reinforcement_methods JSONB DEFAULT '[]'::jsonb,
  
  -- ملاحظات المعلمة
  teacher_notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tracking_student ON session_tracking(student_id);
CREATE INDEX idx_tracking_teacher ON session_tracking(teacher_id);
CREATE INDEX idx_tracking_iep ON session_tracking(iep_plan_id);
CREATE INDEX idx_tracking_dates ON session_tracking(session_date_from, session_date_to);


-- 6️⃣ جدول رسائل ولي الأمر (Parent Messages)
CREATE TABLE IF NOT EXISTS parent_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  from_teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  to_parent_id UUID REFERENCES users(id) ON DELETE SET NULL,
  
  -- محتوى الرسالة
  subject TEXT NOT NULL,
  message_body TEXT NOT NULL,
  
  -- مرفقات
  attachment_url TEXT,
  attachment_name TEXT,
  
  -- حالة الرسالة
  status TEXT DEFAULT 'sent' CHECK (status IN ('draft', 'sent', 'read')),
  
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_student ON parent_messages(student_id);
CREATE INDEX idx_messages_teacher ON parent_messages(from_teacher_id);
CREATE INDEX idx_messages_parent ON parent_messages(to_parent_id);
CREATE INDEX idx_messages_status ON parent_messages(status);


-- ============================================
-- تعطيل RLS مؤقتاً للاختبار
-- ============================================

ALTER TABLE parent_consents DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE initial_student_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE iep_plans DISABLE ROW LEVEL SECURITY;
ALTER TABLE session_tracking DISABLE ROW LEVEL SECURITY;
ALTER TABLE parent_messages DISABLE ROW LEVEL SECURITY;


-- ============================================
-- دوال مساعدة
-- ============================================

-- Trigger لتحديث updated_at
CREATE TRIGGER update_parent_consents_updated_at
  BEFORE UPDATE ON parent_consents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_notes_updated_at
  BEFORE UPDATE ON student_notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_initial_student_data_updated_at
  BEFORE UPDATE ON initial_student_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_iep_plans_updated_at
  BEFORE UPDATE ON iep_plans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_session_tracking_updated_at
  BEFORE UPDATE ON session_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_parent_messages_updated_at
  BEFORE UPDATE ON parent_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- ملاحظات وأمثلة
-- ============================================

-- مثال على tools_used في session_tracking:
-- [
--   "السبورة والأقلام الملونة",
--   "البطاقات أو الصور",
--   "الكتاب المدرسي",
--   "المجسمات",
--   "دفتر الطالبات",
--   "الألوان",
--   "أخرى: ..."
-- ]

-- مثال على teaching_methods:
-- [
--   "توجيه لفظي",
--   "توجيه بدني",
--   "إيماءات",
--   "حوار ونقاش",
--   "تمثيل",
--   "خبرة مباشرة",
--   "محاكاة ونمذجة",
--   "لعب",
--   "قصص",
--   "أخرى: ..."
-- ]

-- مثال على reinforcement_methods:
-- [
--   "تعزيز اجتماعي",
--   "تعزيز غذائي",
--   "تعزيز مادي",
--   "تعزيز نشاطي"
-- ]

-- مثال على behavioral_objectives في session_tracking:
-- [
--   {
--     "objective": "أن تنمي الطالبة مهارة الانتباه",
--     "evaluation": "تحقق"
--   },
--   {
--     "objective": "أن تتعرف على الحروف",
--     "evaluation": "تحقق جزئياً"
--   }
-- ]

-- مثال على semester_goals في iep_plans:
-- [
--   {
--     "id": "sg1",
--     "goal": "تحسين مهارات القراءة",
--     "status": "in_progress"
--   }
-- ]

-- مثال على short_term_goals:
-- [
--   {
--     "id": "stg1",
--     "parent_goal_id": "sg1",
--     "goal": "التعرف على 10 حروف",
--     "status": "achieved"
--   }
-- ]
