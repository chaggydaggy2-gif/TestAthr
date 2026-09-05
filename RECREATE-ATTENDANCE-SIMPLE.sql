-- Drop and recreate attendance table with full permissions
-- This ensures clean slate

-- 1. Drop existing table if any
DROP TABLE IF EXISTS public.attendance CASCADE;

-- 2. Create attendance table
CREATE TABLE public.attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent')),
    teacher_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(student_id, attendance_date)
);

-- 3. Create indexes
CREATE INDEX idx_attendance_student_id ON public.attendance(student_id);
CREATE INDEX idx_attendance_date ON public.attendance(attendance_date);
CREATE INDEX idx_attendance_student_date ON public.attendance(student_id, attendance_date);

-- 4. Disable RLS completely
ALTER TABLE public.attendance DISABLE ROW LEVEL SECURITY;

-- 5. Grant full permissions to authenticated users
GRANT ALL ON public.attendance TO authenticated;
GRANT ALL ON public.attendance TO anon;

-- 6. Make sure the table is fully public
ALTER TABLE public.attendance OWNER TO postgres;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Attendance table recreated successfully!';
    RAISE NOTICE '✅ RLS is DISABLED';
    RAISE NOTICE '✅ Full permissions granted';
END $$;
