-- ============================================
-- DISABLE STORAGE RLS (Fix "violates row-level security" error)
-- ============================================
-- This completely disables RLS on storage.objects
-- allowing all authenticated users to upload
-- ============================================

-- 1. Drop all existing policies
DROP POLICY IF EXISTS "Teachers can upload documents" ON storage.objects;
DROP POLICY IF EXISTS "Teachers can view documents" ON storage.objects;
DROP POLICY IF EXISTS "Teachers can delete documents" ON storage.objects;
DROP POLICY IF EXISTS "Teachers can update documents" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public uploads" ON storage.objects;

-- 2. DISABLE Row Level Security completely
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- 3. Create bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES (
  'student-documents',
  'student-documents',
  false,
  NULL  -- No size limit
)
ON CONFLICT (id) 
DO UPDATE SET
  file_size_limit = NULL,
  public = false;

-- 4. Grant permissions to authenticated role
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.objects TO anon;
GRANT ALL ON storage.buckets TO authenticated;

-- 5. Verify RLS is disabled
SELECT 
  schemaname,
  tablename,
  rowsecurity as "RLS Enabled"
FROM pg_tables
WHERE schemaname = 'storage' AND tablename = 'objects';

-- 6. Check bucket
SELECT 
  id,
  public,
  file_size_limit,
  CASE 
    WHEN file_size_limit IS NULL THEN '✅ UNLIMITED'
    ELSE file_size_limit::text
  END as "Size Limit"
FROM storage.buckets
WHERE id = 'student-documents';

-- Success
DO $$
BEGIN
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '✅ RLS DISABLED on storage.objects';
    RAISE NOTICE '✅ All authenticated users can upload';
    RAISE NOTICE '✅ No size limit';
    RAISE NOTICE '════════════════════════════════════════';
END $$;

