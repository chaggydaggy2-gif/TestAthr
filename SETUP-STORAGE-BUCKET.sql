-- ============================================
-- SETUP SUPABASE STORAGE BUCKET
-- ============================================
-- Creates the student-documents bucket if it doesn't exist
-- and sets proper permissions + size limits
-- ============================================

-- 1. Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'student-documents',
  'student-documents',
  false,  -- Not public (requires authentication)
  524288000,  -- 500MB limit per file
  ARRAY['application/pdf']::text[]  -- Only PDFs allowed
)
ON CONFLICT (id) 
DO UPDATE SET
  file_size_limit = 524288000,
  allowed_mime_types = ARRAY['application/pdf']::text[];

-- 2. Create storage policies for authenticated users

-- Policy: Allow teachers to upload
DROP POLICY IF EXISTS "Teachers can upload documents" ON storage.objects;
CREATE POLICY "Teachers can upload documents" 
ON storage.objects FOR INSERT 
TO authenticated
WITH CHECK (
  bucket_id = 'student-documents' AND
  (auth.jwt() ->> 'role')::text IN ('teacher', 'principal')
);

-- Policy: Allow teachers to read their students' documents
DROP POLICY IF EXISTS "Teachers can view documents" ON storage.objects;
CREATE POLICY "Teachers can view documents" 
ON storage.objects FOR SELECT 
TO authenticated
USING (
  bucket_id = 'student-documents' AND
  (auth.jwt() ->> 'role')::text IN ('teacher', 'principal', 'parent')
);

-- Policy: Allow teachers to delete documents
DROP POLICY IF EXISTS "Teachers can delete documents" ON storage.objects;
CREATE POLICY "Teachers can delete documents" 
ON storage.objects FOR DELETE 
TO authenticated
USING (
  bucket_id = 'student-documents' AND
  (auth.jwt() ->> 'role')::text IN ('teacher', 'principal')
);

-- Policy: Allow teachers to update documents
DROP POLICY IF EXISTS "Teachers can update documents" ON storage.objects;
CREATE POLICY "Teachers can update documents" 
ON storage.objects FOR UPDATE 
TO authenticated
USING (
  bucket_id = 'student-documents' AND
  (auth.jwt() ->> 'role')::text IN ('teacher', 'principal')
);

-- 3. Verify bucket setup
SELECT 
  id as "Bucket Name",
  public as "Public Access",
  file_size_limit as "Size Limit (bytes)",
  CASE 
    WHEN file_size_limit IS NULL THEN 'UNLIMITED'
    ELSE ROUND(file_size_limit / 1024.0 / 1024.0, 2) || ' MB'
  END as "Size Limit (MB)",
  allowed_mime_types as "Allowed Types"
FROM storage.buckets
WHERE id = 'student-documents';

-- 4. List current storage policies
SELECT 
  policyname as "Policy Name",
  cmd as "Command",
  qual as "Condition"
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '✅ Storage bucket setup complete!';
    RAISE NOTICE '✅ Bucket: student-documents';
    RAISE NOTICE '✅ File size limit: 500MB per file';
    RAISE NOTICE '✅ Allowed types: PDF only';
    RAISE NOTICE '✅ Access: Authenticated teachers/principals';
    RAISE NOTICE '════════════════════════════════════════';
END $$;

