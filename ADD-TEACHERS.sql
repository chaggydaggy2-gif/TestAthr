-- ========================================
-- إضافة المعلمات الأربعة
-- مدرسة: الابتدائية 382
-- المديرة: بدرية العتيبي
-- ========================================

-- ملاحظة: يجب تشغيل هذا الملف في Supabase SQL Editor
-- تأكد من وجود school_id للمدرسة أولاً

-- الخطوة 1: الحصول على school_id
DO $$
DECLARE
  v_school_id UUID;
  v_teacher_1_auth_id UUID;
  v_teacher_2_auth_id UUID;
  v_teacher_3_auth_id UUID;
  v_teacher_4_auth_id UUID;
BEGIN
  -- الحصول على school_id من جدول المديرة
  SELECT school_id INTO v_school_id
  FROM users
  WHERE role = 'principal'
  LIMIT 1;

  -- إذا لم يوجد، إنشاء المدرسة
  IF v_school_id IS NULL THEN
    INSERT INTO schools (name, address, phone)
    VALUES ('الابتدائية 382', 'الرياض', '0112345678')
    RETURNING id INTO v_school_id;
  END IF;

  -- ========================================
  -- المعلمة 1: حنان البريك
  -- ========================================
  
  -- إنشاء حساب Auth
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'hanan.albaraik@athr382.sa',
    crypt('Athr2026!', gen_salt('bf')),
    NOW(),
    '{"role": "teacher", "name": "حنان البريك"}'::jsonb,
    NOW(),
    NOW(),
    '',
    ''
  ) RETURNING id INTO v_teacher_1_auth_id;

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
    v_teacher_1_auth_id,
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

  -- ========================================
  -- المعلمة 2: أفنان الحربي
  -- ========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'afnan.alharbi@athr382.sa',
    crypt('Athr2026!', gen_salt('bf')),
    NOW(),
    '{"role": "teacher", "name": "أفنان الحربي"}'::jsonb,
    NOW(),
    NOW(),
    '',
    ''
  ) RETURNING id INTO v_teacher_2_auth_id;

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
    v_teacher_2_auth_id,
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

  -- ========================================
  -- المعلمة 3: هيفاء العتيبي
  -- ========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'haifa.alotaibi@athr382.sa',
    crypt('Athr2026!', gen_salt('bf')),
    NOW(),
    '{"role": "teacher", "name": "هيفاء العتيبي"}'::jsonb,
    NOW(),
    NOW(),
    '',
    ''
  ) RETURNING id INTO v_teacher_3_auth_id;

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
    v_teacher_3_auth_id,
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

  -- ========================================
  -- المعلمة 4: فهيدة العنزي
  -- ========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'fahida.alanazi@athr382.sa',
    crypt('Athr2026!', gen_salt('bf')),
    NOW(),
    '{"role": "teacher", "name": "فهيدة العنزي"}'::jsonb,
    NOW(),
    NOW(),
    '',
    ''
  ) RETURNING id INTO v_teacher_4_auth_id;

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
    v_teacher_4_auth_id,
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

  RAISE NOTICE 'تم إنشاء حسابات المعلمات الأربعة بنجاح! ✅';
  
END $$;

-- ========================================
-- عرض بيانات الدخول
-- ========================================

SELECT 
  '📋 بيانات دخول المعلمات' as info,
  '' as spacer;

SELECT 
  name as "الاسم",
  email as "البريد الإلكتروني",
  'Athr2026!' as "كلمة المرور",
  phone as "رقم الجوال",
  color as "اللون"
FROM users
WHERE role = 'teacher'
  AND email LIKE '%@athr382.sa'
ORDER BY created_at DESC
LIMIT 4;

-- ========================================
-- ملاحظات مهمة
-- ========================================

/*
✅ تم إنشاء 4 حسابات للمعلمات:

1️⃣ حنان البريك
   📧 hanan.albaraik@athr382.sa
   🔑 Athr2026!
   🎨 أزرق

2️⃣ أفنان الحربي
   📧 afnan.alharbi@athr382.sa
   🔑 Athr2026!
   🎨 أخضر نعناعي

3️⃣ هيفاء العتيبي
   📧 haifa.alotaibi@athr382.sa
   🔑 Athr2026!
   🎨 بنفسجي

4️⃣ فهيدة العنزي
   📧 fahida.alanazi@athr382.sa
   🔑 Athr2026!
   🎨 كهرماني

🔐 كلمة المرور الموحدة: Athr2026!
   (يمكن للمعلمات تغييرها بعد الدخول)

✅ الصلاحيات:
   - إضافة طالبات ✓
   - تعديل بيانات الطالبات ✓
   - حذف طالبات ✗
   - إرسال رسائل لأولياء الأمور ✓

📝 خطوات التشغيل:
   1. افتح Supabase Dashboard
   2. اذهب إلى SQL Editor
   3. انسخ والصق هذا الكود
   4. اضغط RUN
   5. شارك بيانات الدخول مع المعلمات

⚠️ ملاحظة: إذا كانت جداول Auth غير متاحة،
   يمكن للمديرة إنشاء الحسابات من واجهة المنصة.
*/
