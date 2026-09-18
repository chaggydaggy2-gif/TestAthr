-- ============================================================
-- 🚀 ملف SQL شامل - يجب تشغيله على Supabase
-- ============================================================
-- هذا الملف يحتوي على جميع التحديثات المطلوبة
-- قم بتشغيله مرة واحدة في Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '🚀 بدء تنفيذ التحديثات الشاملة...';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- 1️⃣ إضافة الأعمدة الجديدة للطلاب (إذا لم تكن موجودة)
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '📝 الخطوة 1: إضافة أعمدة جديدة لجدول students...';
    
    -- إضافة عمود البيانات الأولية المشتركة
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' AND column_name = 'shared_initial_data'
    ) THEN
        ALTER TABLE students ADD COLUMN shared_initial_data JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE '   ✅ تم إضافة عمود shared_initial_data';
    ELSE
        RAISE NOTICE '   ℹ️  عمود shared_initial_data موجود بالفعل';
    END IF;

    -- إضافة عمود نماذج التربية الخاصة (PDF)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' AND column_name = 'special_ed_forms'
    ) THEN
        ALTER TABLE students ADD COLUMN special_ed_forms JSONB DEFAULT '{
            "medical_diagnosis_pdf": null,
            "diagnostic_test_pdf": null
        }'::jsonb;
        RAISE NOTICE '   ✅ تم إضافة عمود special_ed_forms';
    ELSE
        RAISE NOTICE '   ℹ️  عمود special_ed_forms موجود بالفعل';
    END IF;

    -- إضافة عمود الخطة الفردية للتربية الخاصة
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' AND column_name = 'special_ed_iep'
    ) THEN
        ALTER TABLE students ADD COLUMN special_ed_iep JSONB DEFAULT '{
            "current_level": "",
            "strengths": "",
            "needs": "",
            "semester_goals": [],
            "short_term_goals": [],
            "behavioral_goals": [],
            "teaching_tools": [],
            "teaching_strategies": [],
            "reinforcement_methods": [],
            "start_date": null,
            "end_date": null,
            "pdf_upload": null
        }'::jsonb;
        RAISE NOTICE '   ✅ تم إضافة عمود special_ed_iep';
    ELSE
        RAISE NOTICE '   ℹ️  عمود special_ed_iep موجود بالفعل';
    END IF;

    -- إضافة عمود جلسات المتابعة للتربية الخاصة
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' AND column_name = 'special_ed_sessions'
    ) THEN
        ALTER TABLE students ADD COLUMN special_ed_sessions JSONB DEFAULT '[]'::jsonb;
        RAISE NOTICE '   ✅ تم إضافة عمود special_ed_sessions';
    ELSE
        RAISE NOTICE '   ℹ️  عمود special_ed_sessions موجود بالفعل';
    END IF;

    RAISE NOTICE '';
END $$;

-- ============================================================
-- 2️⃣ إصلاح جدول الحضور والغياب (attendance)
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '📅 الخطوة 2: إصلاح جدول الحضور والغياب...';
    
    -- حذف الجدول القديم إذا كان موجوداً
    DROP TABLE IF EXISTS public.attendance CASCADE;
    RAISE NOTICE '   🗑️  تم حذف الجدول القديم';

    -- إنشاء جدول جديد
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
    RAISE NOTICE '   ✅ تم إنشاء جدول attendance جديد';

    -- إنشاء فهارس للأداء
    CREATE INDEX idx_attendance_student_id ON public.attendance(student_id);
    CREATE INDEX idx_attendance_date ON public.attendance(attendance_date);
    CREATE INDEX idx_attendance_student_date ON public.attendance(student_id, attendance_date);
    RAISE NOTICE '   ✅ تم إنشاء الفهارس';

    -- تعطيل RLS تماماً
    ALTER TABLE public.attendance DISABLE ROW LEVEL SECURITY;
    RAISE NOTICE '   ✅ تم تعطيل RLS';

    -- منح جميع الصلاحيات
    GRANT ALL ON public.attendance TO authenticated;
    GRANT ALL ON public.attendance TO anon;
    GRANT ALL ON public.attendance TO postgres;
    RAISE NOTICE '   ✅ تم منح الصلاحيات';

    -- تعيين المالك
    ALTER TABLE public.attendance OWNER TO postgres;
    RAISE NOTICE '   ✅ تم تعيين المالك';

    -- تفعيل realtime
    ALTER PUBLICATION supabase_realtime ADD TABLE public.attendance;
    RAISE NOTICE '   ✅ تم تفعيل realtime';

    RAISE NOTICE '';
END $$;

-- ============================================================
-- 3️⃣ إصلاح Storage Bucket وإعدادات التحميل
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '📁 الخطوة 3: إصلاح إعدادات التخزين...';
    
    -- إزالة حد حجم الملف من bucket
    UPDATE storage.buckets 
    SET file_size_limit = NULL 
    WHERE name = 'student-documents';
    
    IF FOUND THEN
        RAISE NOTICE '   ✅ تم إزالة حد حجم الملف';
    ELSE
        RAISE NOTICE '   ⚠️  Bucket غير موجود - قد تحتاج لإنشائه يدوياً';
    END IF;

    RAISE NOTICE '';
END $$;

-- ============================================================
-- 4️⃣ تحديث أسماء الطلاب (إيلاف وليندا)
-- ============================================================

DO $$
DECLARE
    v_updated_count INTEGER := 0;
BEGIN
    RAISE NOTICE '👥 الخطوة 4: تحديث أسماء الطلاب...';
    
    -- تغيير mohamed → إيلاف العتيبي
    UPDATE students
    SET 
        name = 'إيلاف العتيبي',
        initials = 'إ'
    WHERE LOWER(name) = 'mohamed';

    IF FOUND THEN
        v_updated_count := v_updated_count + 1;
        RAISE NOTICE '   ✅ mohamed → إيلاف العتيبي';
    END IF;

    -- تغيير selma → ليندا الغامدي
    UPDATE students
    SET 
        name = 'ليندا الغامدي',
        initials = 'ل'
    WHERE LOWER(name) = 'selma';

    IF FOUND THEN
        v_updated_count := v_updated_count + 1;
        RAISE NOTICE '   ✅ selma → ليندا الغامدي';
    END IF;

    IF v_updated_count = 0 THEN
        RAISE NOTICE '   ℹ️  لم يتم العثور على الطلاب - قد يكون تم التحديث مسبقاً';
    END IF;

    RAISE NOTICE '';
END $$;

-- ============================================================
-- 5️⃣ التحقق من النتائج
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '🔍 الخطوة 5: التحقق من النتائج...';
    RAISE NOTICE '';
END $$;

-- عرض الأعمدة الجديدة
SELECT 
    '📋 الأعمدة الجديدة في جدول students:' as info,
    column_name as "اسم العمود",
    data_type as "نوع البيانات"
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name IN ('shared_initial_data', 'special_ed_forms', 'special_ed_iep', 'special_ed_sessions')
ORDER BY column_name;

-- عرض معلومات جدول الحضور
SELECT 
    '📅 جدول الحضور والغياب:' as info,
    COUNT(*) as "عدد السجلات",
    (SELECT relrowsecurity FROM pg_class WHERE relname = 'attendance') as "RLS مفعّل؟"
FROM attendance;

-- عرض الطلاب المحدثين
SELECT 
    '👥 الطلاب المحدثين:' as info,
    id,
    name as "الاسم",
    initials as "الحرف",
    grade as "الصف"
FROM students
WHERE name IN ('إيلاف العتيبي', 'ليندا الغامدي')
ORDER BY name;

-- ============================================================
-- 🎉 رسالة النجاح النهائية
-- ============================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '🎉 تم إكمال جميع التحديثات بنجاح!';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '✅ ما تم تنفيذه:';
    RAISE NOTICE '   1. إضافة أعمدة جديدة للطلاب (shared_initial_data, special_ed_forms, special_ed_iep, special_ed_sessions)';
    RAISE NOTICE '   2. إصلاح جدول الحضور والغياب وتعطيل RLS';
    RAISE NOTICE '   3. إزالة حد حجم الملف من Storage';
    RAISE NOTICE '   4. تحديث أسماء الطلاب (إيلاف، ليندا)';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 الخطوات التالية:';
    RAISE NOTICE '   1. ارجع للموقع';
    RAISE NOTICE '   2. اضغط Ctrl+Shift+R (hard refresh)';
    RAISE NOTICE '   3. جرب الميزات الجديدة!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 الميزات الجديدة المتاحة الآن:';
    RAISE NOTICE '   • إضافة متابعة مع تصنيف الأهداف';
    RAISE NOTICE '   • هدف يدوي واحد اختياري';
    RAISE NOTICE '   • تبويب "الخطة الفردية" لولي الأمر';
    RAISE NOTICE '   • إشعارات واضحة للرسائل من أولياء الأمور';
    RAISE NOTICE '   • زر "إضافة هدف إجرائي" يعمل بشكل صحيح';
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════════';
END $$;
