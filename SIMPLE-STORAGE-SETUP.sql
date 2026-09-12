-- ============================================
-- SIMPLE STORAGE BUCKET SETUP
-- ============================================
-- Creates bucket with NO RLS (Row Level Security)
-- This allows ALL authenticated users to upload
-- ============================================

-- 1. Create the bucket (no RLS)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'student-documents',
  'student-documents',
  false,  -- Not public
  NULL,   -- NO SIZE LIMIT
  NULL    -- Allow ALL file types
)
ON CONFLICT (id) 
DO UPDATE SET
  file_size_limit = NULL,
  allowed_mime_types = NULL;

-- 2. DISABLE RLS on storage.objects for this bucket
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- 3. Grant all permissions to authenticated users
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;

-- 4. Verify bucket
SELECT 
  id as "Bucket",
  public as "Public",
  file_size_limit as "Size Limit",
  CASE 
    WHEN file_size_limit IS NULL THEN '✅ UNLIMITED'
    ELSE file_size_limit::text || ' bytes'
  END as "Limit Status"
FROM storage.buckets
WHERE id = 'student-documents';

-- Success
DO $$
BEGIN
    RAISE NOTICE '✅ Bucket created with NO size limit!';
    RAISE NOTICE '✅ RLS disabled - all authenticated users can upload';
END $$;

