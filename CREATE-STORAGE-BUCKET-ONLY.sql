-- ============================================
-- CREATE STORAGE BUCKET (Simple version)
-- ============================================
-- Just creates the bucket with no size limit
-- Go to Supabase Dashboard → Storage → student-documents → Policies
-- to manually add policies in the UI
-- ============================================

-- Create bucket with no size limit
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

-- Verify
SELECT 
  id as "Bucket Name",
  public as "Public",
  file_size_limit as "Size Limit",
  CASE 
    WHEN file_size_limit IS NULL THEN '✅ UNLIMITED'
    ELSE file_size_limit::text || ' bytes'
  END as "Status"
FROM storage.buckets
WHERE id = 'student-documents';

-- Success
DO $$
BEGIN
    RAISE NOTICE '✅ Bucket created: student-documents';
    RAISE NOTICE '✅ Size limit: UNLIMITED';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 NEXT STEP:';
    RAISE NOTICE 'Go to Supabase Dashboard → Storage → Policies';
    RAISE NOTICE 'Click "New Policy" → "Custom" → Use this:';
    RAISE NOTICE '';
    RAISE NOTICE 'Policy name: Allow authenticated uploads';
    RAISE NOTICE 'Target roles: authenticated';
    RAISE NOTICE 'Policy command: INSERT';
    RAISE NOTICE 'WITH CHECK expression: bucket_id = ''student-documents''';
    RAISE NOTICE '';
    RAISE NOTICE 'Then create similar policies for SELECT, UPDATE, DELETE';
END $$;

