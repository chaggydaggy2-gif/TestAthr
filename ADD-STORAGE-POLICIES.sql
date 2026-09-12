-- ============================================
-- ADD STORAGE POLICIES (Allow all operations)
-- ============================================
-- Creates 4 policies for INSERT, SELECT, UPDATE, DELETE
-- Run this in Supabase SQL Editor
-- ============================================

-- Policy 1: Allow INSERT (uploads)
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'student-documents');

-- Policy 2: Allow SELECT (reads/views)
CREATE POLICY "Allow authenticated reads"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'student-documents');

-- Policy 3: Allow UPDATE (modify files)
CREATE POLICY "Allow authenticated updates"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'student-documents')
WITH CHECK (bucket_id = 'student-documents');

-- Policy 4: Allow DELETE (remove files)
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'student-documents');

-- Verify all policies created
SELECT 
  policyname as "Policy Name",
  cmd as "Operation"
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%authenticated%'
ORDER BY cmd;

-- Success
DO $$
BEGIN
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '✅ All 4 storage policies created!';
    RAISE NOTICE '✅ INSERT: Allow uploads';
    RAISE NOTICE '✅ SELECT: Allow reads (view PDFs)';
    RAISE NOTICE '✅ UPDATE: Allow updates';
    RAISE NOTICE '✅ DELETE: Allow deletes';
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 Next: Refresh browser and try uploading!';
END $$;

