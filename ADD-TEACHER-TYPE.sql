-- =========================================================
-- Add teacher_type field to support Special Ed Teachers
-- =========================================================
-- Run this in Supabase SQL Editor

-- 1. Add teacher_type column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS teacher_type TEXT 
CHECK (teacher_type IN ('speech', 'special_ed', 'vice_principal'));

-- 2. Set default value for existing teachers (assume they are speech teachers)
UPDATE users 
SET teacher_type = 'speech' 
WHERE role = 'teacher' AND teacher_type IS NULL;

-- 3. Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_users_teacher_type ON users(teacher_type);

-- 4. Update existing teachers based on their title (optional - adjust as needed)
-- If you want to identify existing special ed teachers by their title
-- UPDATE users SET teacher_type = 'special_ed' WHERE role = 'teacher' AND title ILIKE '%تربية خاصة%';

-- 5. Create storage bucket for PDF uploads (medical diagnosis, diagnostic tests, IEP PDFs)
INSERT INTO storage.buckets (id, name, public)
VALUES ('student-documents', 'student-documents', false)
ON CONFLICT (id) DO NOTHING;

-- 6. Set up RLS policies for student documents storage
CREATE POLICY "Teachers can upload student documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'student-documents' AND
  (auth.uid() IN (SELECT auth_id FROM users WHERE role IN ('teacher', 'principal')))
);

CREATE POLICY "Teachers can view student documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'student-documents' AND
  (auth.uid() IN (SELECT auth_id FROM users WHERE role IN ('teacher', 'principal')))
);

CREATE POLICY "Teachers can delete student documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'student-documents' AND
  (auth.uid() IN (SELECT auth_id FROM users WHERE role IN ('teacher', 'principal')))
);

CREATE POLICY "Parents can view their child's documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'student-documents' AND
  (
    -- Extract student_id from path (format: student_id/document_type/filename)
    split_part(name, '/', 1)::uuid IN (
      SELECT id::text FROM students WHERE parent_id IN (
        SELECT id FROM users WHERE auth_id = auth.uid()
      )
    )
  )
);

-- 7. Add shared_initial_data JSONB column to students table for البيانات الأولية
ALTER TABLE students
ADD COLUMN IF NOT EXISTS shared_initial_data JSONB DEFAULT '{}'::jsonb;

-- 8. Add special_ed_forms JSONB column to students table
ALTER TABLE students
ADD COLUMN IF NOT EXISTS special_ed_forms JSONB DEFAULT '{
  "medical_diagnosis_pdf": null,
  "diagnostic_test_pdf": null,
  "student_notes": []
}'::jsonb;

-- 9. Add special_ed_iep JSONB column to students table (different from speech teacher IEP)
ALTER TABLE students
ADD COLUMN IF NOT EXISTS special_ed_iep JSONB DEFAULT '{
  "current_level": "",
  "strengths": "",
  "needs": "",
  "semester_goals": [],
  "short_term_goals": [],
  "behavioral_goals": [],
  "teaching_tools": [],
  "teaching_strategies": [],
  "start_date": null,
  "end_date": null,
  "pdf_upload": null
}'::jsonb;

-- 10. Add special_ed_sessions JSONB array to students table
ALTER TABLE students
ADD COLUMN IF NOT EXISTS special_ed_sessions JSONB DEFAULT '[]'::jsonb;

-- =========================================================
-- Verification Queries (run these to check)
-- =========================================================

-- Check teacher_type column
-- SELECT id, name, role, teacher_type, title FROM users WHERE role = 'teacher';

-- Check storage bucket
-- SELECT * FROM storage.buckets WHERE id = 'student-documents';

-- Check new student columns
-- SELECT column_name, data_type FROM information_schema.columns 
-- WHERE table_name = 'students' 
-- AND column_name IN ('shared_initial_data', 'special_ed_forms', 'special_ed_iep', 'special_ed_sessions');
