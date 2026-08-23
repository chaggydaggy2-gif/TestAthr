-- ========================================
-- إضافة المعلمات الأربعة - نسخة سهلة ومبسطة
-- الابتدائية 382 - بدرية العتيبي
-- ========================================

-- ⚠️ هام: قم بتشغيل هذا الملف في Supabase SQL Editor
-- خطوات التشغيل:
-- 1. افتح Supabase Dashboard
-- 2. اذهب إلى SQL Editor
-- 3. انسخ والصق هذا الكود بالكامل
-- 4. اضغط RUN
-- 5. انتظر رسالة النجاح

-- ========================================
-- إنشاء المعلمات الأربعة
-- ========================================

DO $$
DECLARE
  v_school_id UUID;
  v_teacher_auth_id UUID;
  v_teacher_count INTEGER := 0;
BEGIN
  -- الحصول على school_id من المديرة الحالية
  SELECT school_id INTO v_school_id
  FROM users
  WHERE role = 'principal'
  ORDER BY created_at DESC
  LIMIT 1;

  -- إذا لم يوجد school_id، إنشاء مدرسة جديدة
  IF v_school_id IS NULL THEN
    INSERT INTO schools (name, address, phone)
    VALUES ('الابتدائية 382', 'الرياض', '0112345678')
    RETURNING id INTO v_school_id;
    RAISE NOTICE '✅ تم إنشاء المدرسة: الابتدائية 382';
  ELSE
    RAISE NOTICE '✅ تم العثور على المدرسة: %', v_school_id;
  END IF;

  -- ========================================
  -- المعلمة 1: حنان البريك
  -- ========================================
  
  BEGIN
    -- إنشاء حساب Auth
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'hanan.albaraik@athr382.sa',
      crypt('Athr2026!', gen_salt('bf')),
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"role": "teacher", "name": "حنان البريك"}'::jsonb,
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    ) RETURNING id INTO v_teacher_auth_id;

    -- إنشاء ملف المعلمة
    INSERT INTO users (
      auth_id,
      school_id,
      role,
      name,
      email,
      phone,
      title,
      color,
      initials,
      permissions
    ) VALUES (
      v_teacher_auth_id,
      v_school_id,
      'teacher',
      'حنان البريك',
      'hanan.albaraik@athr382.sa',
      '0501234567',
      'معلمة تربية خاصة',
      'c-blue',
      'ح',
      jsonb_build_object(
        'can_add_students', true,
        'can_edit_students', true,
        'can_delete_students', false,
        'can_message_parents', true
      )
    );

    v_teacher_count := v_teacher_count + 1;
    RAISE NOTICE '✅ تم إنشاء حساب: حنان البريك (hanan.albaraik@athr382.sa)';
    
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ حساب حنان البريك موجود مسبقاً';
  END;

  -- ========================================
  -- المعلمة 2: أفنان الحربي
  -- ========================================
  
  BEGIN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'afnan.alharbi@athr382.sa',
      crypt('Athr2026!', gen_salt('bf')),
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"role": "teacher", "name": "أفنان الحربي"}'::jsonb,
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    ) RETURNING id INTO v_teacher_auth_id;

    INSERT INTO users (
      auth_id,
      school_id,
      role,
      name,
      email,
      phone,
      title,
      color,
      initials,
      permissions
    ) VALUES (
      v_teacher_auth_id,
      v_school_id,
      'teacher',
      'أفنان الحربي',
      'afnan.alharbi@athr382.sa',
      '0502345678',
      'معلمة تربية خاصة',
      'c-mint',
      'أ',
      jsonb_build_object(
        'can_add_students', true,
        'can_edit_students', true,
        'can_delete_students', false,
        'can_message_parents', true
      )
    );

    v_teacher_count := v_teacher_count + 1;
    RAISE NOTICE '✅ تم إنشاء حساب: أفنان الحربي (afnan.alharbi@athr382.sa)';
    
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ حساب أفنان الحربي موجود مسبقاً';
  END;

  -- ========================================
  -- المعلمة 3: هيفاء العتيبي
  -- ========================================
  
  BEGIN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'haifa.alotaibi@athr382.sa',
      crypt('Athr2026!', gen_salt('bf')),
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"role": "teacher", "name": "هيفاء العتيبي"}'::jsonb,
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    ) RETURNING id INTO v_teacher_auth_id;

    INSERT INTO users (
      auth_id,
      school_id,
      role,
      name,
      email,
      phone,
      title,
      color,
      initials,
      permissions
    ) VALUES (
      v_teacher_auth_id,
      v_school_id,
      'teacher',
      'هيفاء العتيبي',
      'haifa.alotaibi@athr382.sa',
      '0503456789',
      'معلمة تربية خاصة',
      'c-purple',
      'هـ',
      jsonb_build_object(
        'can_add_students', true,
        'can_edit_students', true,
        'can_delete_students', false,
        'can_message_parents', true
      )
    );

    v_teacher_count := v_teacher_count + 1;
    RAISE NOTICE '✅ تم إنشاء حساب: هيفاء العتيبي (haifa.alotaibi@athr382.sa)';
    
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ حساب هيفاء العتيبي موجود مسبقاً';
  END;

  -- ========================================
  -- المعلمة 4: فهيدة العنزي
  -- ========================================
  
  BEGIN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'fahida.alanazi@athr382.sa',
      crypt('Athr2026!', gen_salt('bf')),
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"role": "teacher", "name": "فهيدة العنزي"}'::jsonb,
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    ) RETURNING id INTO v_teacher_auth_id;

    INSERT INTO users (
      auth_id,
      school_id,
      role,
      name,
      email,
      phone,
      title,
      color,
      initials,
      permissions
    ) VALUES (
      v_teacher_auth_id,
      v_school_id,
      'teacher',
      'فهيدة العنزي',
      'fahida.alanazi@athr382.sa',
      '0504567890',
      'معلمة تربية خاصة',
      'c-amber',
      'ف',
      jsonb_build_object(
        'can_add_students', true,
        'can_edit_students', true,
        'can_delete_students', false,
        'can_message_parents', true
      )
    );

    v_teacher_count := v_teacher_count + 1;
    RAISE NOTICE '✅ تم إنشاء حساب: فهيدة العنزي (fahida.alanazi@athr382.sa)';
    
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ حساب فهيدة العنزي موجود مسبقاً';
  END;

  -- ========================================
  -- رسالة النجاح النهائية
  -- ========================================
  
  IF v_teacher_count > 0 THEN
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '🎉 تم إنشاء % حسابات معلمات بنجاح!', v_teacher_count;
    RAISE NOTICE '════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📋 بيانات الدخول الموحدة:';
    RAISE NOTICE '🔑 كلمة المرور: Athr2026!';
    RAISE NOTICE '';
    RAISE NOTICE '✅ يمكن للمعلمات الآن تسجيل الدخول إلى المنصة';
  END IF;

END $$;

-- ========================================
-- عرض النتائج
-- ========================================

-- عرض جميع المعلمات المضافة حديثاً
SELECT 
  '📋 بيانات المعلمات المسجلات' as info;

SELECT 
  name as "الاسم",
  email as "البريد الإلكتروني",
  phone as "الجوال",
  title as "المسمى",
  color as "اللون",
  'Athr2026!' as "كلمة المرور",
  created_at as "تاريخ الإنشاء"
FROM users
WHERE role = 'teacher'
  AND email LIKE '%@athr382.sa'
ORDER BY created_at DESC;

-- التحقق من عدد المعلمات
SELECT 
  COUNT(*) as "عدد المعلمات الكلي"
FROM users
WHERE role = 'teacher'
  AND email LIKE '%@athr382.sa';

-- ========================================
-- ملاحظات مهمة
-- ========================================

/*

🎉 تم بنجاح! ستظهر لك الآن:

✅ قائمة بأسماء المعلمات الأربعة
✅ بيانات الدخول لكل معلمة
✅ تأكيد عدد الحسابات المنشأة

────────────────────────────────────────

📧 البريد الإلكتروني للمعلمات:

1. hanan.albaraik@athr382.sa
2. afnan.alharbi@athr382.sa
3. haifa.alotaibi@athr382.sa
4. fahida.alanazi@athr382.sa

🔑 كلمة المرور الموحدة: Athr2026!

────────────────────────────────────────

⚠️ نصائح الأمان:

• شارك بيانات الدخول بطريقة آمنة
• انصح المعلمات بتغيير كلمة المرور
• احفظ نسخة احتياطية من البيانات

────────────────────────────────────────

🚀 الخطوة التالية:

1. شارك بيانات الدخول مع المعلمات
2. اطلب منهن تسجيل الدخول للمنصة
3. ابدأ بإضافة الطالبات!

════════════════════════════════════════

*/
