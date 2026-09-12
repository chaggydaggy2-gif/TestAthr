-- ============================================
-- FIX STORAGE POLICIES (Allow all uploads)
-- ============================================
-- Creates permissive policies for authenticated users
-- ============================================

-- 1. Create bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES (
  'student-documents',
  'student-documents',
  false,
  NULL  -- No size limit
)
ON CONFLICT (id) 
DO UPDATE SET
  file_size_limit = NULL;

-- 2. Drop existing policies
DROP POLICY IF EXISTS "Allow all authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow all authenticated reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow all authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow all authenticated deletes" ON storage.objects;

-- 3. Create PERMISSIVE policies (allow everything for authenticated users)
CREATE POLICY "Allow all authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'student-documents');

CREATE POLICY "Allow all authenticated reads"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'student-documents');

CREATE POLICY "Allow all authenticated updates"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'student-documents')
WITH CHECK (bucket_id = 'student-documents');

CREATE POLICY "Allow all authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'student-documents');

-- 4. Verify bucket
SELECT 
  id as "Bucket",
  public as "Public",
  file_size_limit as "Size Limit",
  CASE 
    WHEN file_size_limit IS NULL THEN '✅ UNLIMITED'
    ELSE file_size_limit::text || ' bytes'
  END as "Status"
FROM storage.buckets
WHERE id = 'student-documents';

-- 5. List policies
SELECT 
  policyname as "Policy",
  cmd as "Type"
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%authenticated%'
ORDER BY policyname;

-- Success
DO $$
BEGIN
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '✅ Storage policies created!';
    RAISE NOTICE '✅ All authenticated users can upload/view/delete';
    RAISE NOTICE '✅ No size limit on bucket';
    RAISE NOTICE '════════════════════════════════════════';
END $$;

