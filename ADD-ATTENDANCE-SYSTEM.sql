-- ============================================
-- Attendance System for Students
-- ============================================
-- This script adds attendance tracking functionality
-- All teachers can view and mark attendance for their school's students
-- Real-time sync across teacher accounts
-- ============================================

-- 1. Create attendance table
CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent')), -- 'present' = ح, 'absent' = غ
    teacher_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    
    -- Ensure one record per student per day
    UNIQUE(student_id, attendance_date)
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON public.attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON public.attendance(attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_teacher_id ON public.attendance(teacher_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON public.attendance(student_id, attendance_date);

-- 3. Enable Row Level Security
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for attendance table

-- Teachers can view attendance for students in their school
DROP POLICY IF EXISTS "Teachers can view attendance in their school" ON public.attendance;
CREATE POLICY "Teachers can view attendance in their school"
ON public.attendance
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 
        FROM public.users u
        JOIN public.students s ON s.school_id = u.school_id
        WHERE u.id = auth.uid()
        AND u.role = 'teacher'
        AND s.id = attendance.student_id
    )
);

-- Teachers can insert attendance for students in their school
DROP POLICY IF EXISTS "Teachers can insert attendance in their school" ON public.attendance;
CREATE POLICY "Teachers can insert attendance in their school"
ON public.attendance
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 
        FROM public.users u
        JOIN public.students s ON s.school_id = u.school_id
        WHERE u.id = auth.uid()
        AND u.role = 'teacher'
        AND s.id = attendance.student_id
    )
);

-- Teachers can update attendance they created or in their school
DROP POLICY IF EXISTS "Teachers can update attendance in their school" ON public.attendance;
CREATE POLICY "Teachers can update attendance in their school"
ON public.attendance
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 
        FROM public.users u
        JOIN public.students s ON s.school_id = u.school_id
        WHERE u.id = auth.uid()
        AND u.role = 'teacher'
        AND s.id = attendance.student_id
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 
        FROM public.users u
        JOIN public.students s ON s.school_id = u.school_id
        WHERE u.id = auth.uid()
        AND u.role = 'teacher'
        AND s.id = attendance.student_id
    )
);

-- Teachers can delete attendance in their school
DROP POLICY IF EXISTS "Teachers can delete attendance in their school" ON public.attendance;
CREATE POLICY "Teachers can delete attendance in their school"
ON public.attendance
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 
        FROM public.users u
        JOIN public.students s ON s.school_id = u.school_id
        WHERE u.id = auth.uid()
        AND u.role = 'teacher'
        AND s.id = attendance.student_id
    )
);

-- Parents can view their child's attendance
DROP POLICY IF EXISTS "Parents can view their child attendance" ON public.attendance;
CREATE POLICY "Parents can view their child attendance"
ON public.attendance
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        WHERE u.id = auth.uid()
        AND u.role = 'parent'
        AND u.student_id = attendance.student_id
    )
);

-- 5. Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_attendance_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Create trigger for updated_at
DROP TRIGGER IF EXISTS set_attendance_updated_at ON public.attendance;
CREATE TRIGGER set_attendance_updated_at
    BEFORE UPDATE ON public.attendance
    FOR EACH ROW
    EXECUTE FUNCTION update_attendance_updated_at();

-- 7. Simple attendance statistics query
-- You can run this manually when needed instead of creating a view
-- 
-- Example query to get attendance stats:
-- 
-- SELECT 
--     s.id as student_id,
--     s.name as student_name,
--     DATE_TRUNC('month', a.attendance_date)::date as month,
--     COUNT(*) FILTER (WHERE a.status = 'present') as total_present,
--     COUNT(*) FILTER (WHERE a.status = 'absent') as total_absent,
--     COUNT(*) as total_days
-- FROM students s
-- LEFT JOIN attendance a ON a.student_id = s.id
-- GROUP BY s.id, s.name, DATE_TRUNC('month', a.attendance_date);

-- Skip creating the view to avoid schema issues

-- 8. Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.attendance TO authenticated;

-- Note: attendance_stats view was skipped to avoid schema compatibility issues
-- You can calculate statistics in your application logic instead

-- ============================================
-- NOTES:
-- ============================================
-- 1. Run this script in Supabase SQL Editor
-- 2. All teachers in same school can see all students' attendance
-- 3. Attendance is marked per day (one record per student per day)
-- 4. Status: 'present' = حاضر (ح), 'absent' = غائب (غ)
-- 5. Real-time subscriptions will be handled in app.js
-- 6. Parents can view their child's attendance (read-only)
-- ============================================

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Attendance system tables created successfully!';
    RAISE NOTICE 'Table: attendance';
    RAISE NOTICE 'Indexes: 4 created';
    RAISE NOTICE 'RLS Policies: 5 applied';
    RAISE NOTICE 'Note: Statistics are calculated in the app, no view needed';
END $$;
