-- ============================================
-- FIX SUPABASE STORAGE SIZE LIMIT
-- ============================================
-- This removes the file size limit on the storage bucket
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Update storage bucket file size limit (set to 500MB or remove limit)
UPDATE storage.buckets
SET file_size_limit = 524288000  -- 500MB in bytes (or NULL for unlimited)
WHERE id = 'student-documents';

-- 2. Check current bucket settings
SELECT 
  id as "Bucket Name",
  file_size_limit as "File Size Limit (bytes)",
  CASE 
    WHEN file_size_limit IS NULL THEN 'UNLIMITED'
    ELSE ROUND(file_size_limit / 1024.0 / 1024.0, 2) || ' MB'
  END as "Limit (MB)",
  public as "Public",
  allowed_mime_types as "Allowed MIME Types"
FROM storage.buckets
WHERE id = 'student-documents';

-- 3. Alternative: Remove limit completely (uncomment if you want unlimited)
-- UPDATE storage.buckets
-- SET file_size_limit = NULL
-- WHERE id = 'student-documents';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Storage bucket size limit updated!';
    RAISE NOTICE '✅ New limit: 500MB per file';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 Next steps:';
    RAISE NOTICE '1. Refresh your browser';
    RAISE NOTICE '2. Try uploading PDF again';
    RAISE NOTICE '3. Should work now!';
END $$;

