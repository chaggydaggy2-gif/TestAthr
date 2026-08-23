-- ========================================
-- إضافة المعلمات الأربعة (نسخة مبسطة)
-- مدرسة: الابتدائية 382
-- ========================================

-- هذا الملف لإنشاء ملفات المعلمات فقط
-- سيتم إنشاء حسابات Auth من واجهة المنصة (Dashboard)

-- ========================================
-- الخطوة 1: التأكد من وجود المدرسة
-- ========================================

-- إذا لم تكن المدرسة موجودة، قم بإنشائها
INSERT INTO schools (name, address, phone)
SELECT 'الابتدائية 382', 'الرياض', '0112345678'
WHERE NOT EXISTS (
  SELECT 1 FROM schools WHERE name = 'الابتدائية 382'
);

-- ========================================
-- الخطوة 2: إضافة المعلمات
-- ========================================

-- ⚠️ ملاحظة: استبدل 'YOUR_AUTH_ID_HERE' بمعرفات Auth الفعلية
-- بعد إنشاء الحسابات من Supabase Authentication

-- المعلمة 1: حنان البريك
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
  permissions,
  created_at,
  updated_at
) VALUES (
  'REPLACE_WITH_AUTH_ID_1'::uuid,  -- ⚠️ استبدل هذا
  (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1),
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
  ),
  NOW(),
  NOW()
);

-- المعلمة 2: أفنان الحربي
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
  permissions,
  created_at,
  updated_at
) VALUES (
  'REPLACE_WITH_AUTH_ID_2'::uuid,  -- ⚠️ استبدل هذا
  (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1),
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
  ),
  NOW(),
  NOW()
);

-- المعلمة 3: هيفاء العتيبي
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
  permissions,
  created_at,
  updated_at
) VALUES (
  'REPLACE_WITH_AUTH_ID_3'::uuid,  -- ⚠️ استبدل هذا
  (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1),
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
  ),
  NOW(),
  NOW()
);

-- المعلمة 4: فهيدة العنزي
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
  permissions,
  created_at,
  updated_at
) VALUES (
  'REPLACE_WITH_AUTH_ID_4'::uuid,  -- ⚠️ استبدل هذا
  (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1),
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
  ),
  NOW(),
  NOW()
);

-- عرض النتائج
SELECT 
  name as "الاسم",
  email as "البريد الإلكتروني",
  phone as "الجوال",
  title as "المسمى الوظيفي",
  color as "اللون"
FROM users
WHERE role = 'teacher'
  AND school_id = (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1)
ORDER BY created_at DESC;

-- ========================================
-- 📋 بيانات دخول المعلمات
-- ========================================

/*
✅ الحسابات المطلوبة:

1️⃣ حنان البريك
   📧 hanan.albaraik@athr382.sa
   🔑 [كلمة المرور التي تحددها]
   📱 0501234567
   🎨 أزرق (c-blue)

2️⃣ أفنان الحربي
   📧 afnan.alharbi@athr382.sa
   🔑 [كلمة المرور التي تحددها]
   📱 0502345678
   🎨 أخضر (c-mint)

3️⃣ هيفاء العتيبي
   📧 haifa.alotaibi@athr382.sa
   🔑 [كلمة المرور التي تحددها]
   📱 0503456789
   🎨 بنفسجي (c-purple)

4️⃣ فهيدة العنزي
   📧 fahida.alanazi@athr382.sa
   🔑 [كلمة المرور التي تحددها]
   📱 0504567890
   🎨 كهرماني (c-amber)

🔐 الصلاحيات الممنوحة:
   ✅ إضافة طالبات
   ✅ تعديل بيانات الطالبات
   ❌ حذف طالبات
   ✅ إرسال رسائل لأولياء الأمور

📝 خطوات التنفيذ:

الطريقة 1️⃣ - من خلال واجهة المنصة (الأسهل):
   1. سجلي دخول كمديرة
   2. اذهبي لتبويب "المعلمات"
   3. اضغطي "إضافة معلمة"
   4. أدخلي البيانات لكل معلمة
   5. سيتم إنشاء الحساب تلقائياً

الطريقة 2️⃣ - من خلال Supabase (للمطورين):
   1. افتح Supabase Dashboard
   2. اذهب إلى Authentication > Users
   3. أنشئ 4 مستخدمين جدد بالبريد الإلكتروني المذكور
   4. احصل على UUID لكل مستخدم
   5. استبدل 'REPLACE_WITH_AUTH_ID_X' في هذا الملف
   6. شغل الكود في SQL Editor
*/
