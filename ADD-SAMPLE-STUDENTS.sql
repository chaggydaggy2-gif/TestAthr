-- ========================================
-- إضافة طالبات تجريبية
-- الابتدائية 382
-- ========================================

-- ⚠️ هام: شغّل هذا الملف في Supabase SQL Editor
-- سيضيف 5 طالبات تجريبية لاختبار المنصة

DO $$
DECLARE
  v_school_id UUID;
  v_teacher_id UUID;
  v_student_count INTEGER := 0;
BEGIN
  -- الحصول على school_id
  SELECT id INTO v_school_id
  FROM schools
  WHERE name = 'الابتدائية 382'
  LIMIT 1;

  -- الحصول على معلمة (أي معلمة)
  SELECT id INTO v_teacher_id
  FROM users
  WHERE role = 'teacher'
  ORDER BY created_at
  LIMIT 1;

  IF v_school_id IS NULL THEN
    RAISE EXCEPTION 'المدرسة غير موجودة! شغّل CREATE-TEACHERS-EASY.sql أولاً';
  END IF;

  RAISE NOTICE '✅ School ID: %', v_school_id;
  RAISE NOTICE '✅ Teacher ID: %', v_teacher_id;

  -- ========================================
  -- الطالبة 1: نورة أحمد
  -- ========================================
  BEGIN
    INSERT INTO students (
      school_id,
      teacher_id,
      name,
      grade,
      age,
      color,
      initials,
      parent_phone,
      invite_code,
      archived,
      forms,
      schedule,
      created_at,
      updated_at
    ) VALUES (
      v_school_id,
      v_teacher_id,
      'نورة أحمد',
      'الصف الأول أ',
      7,
      'c-blue',
      'ن',
      '0501111111',
      'INV' || floor(random() * 900000 + 100000)::text,
      false,
      '{}'::jsonb,
      '[]'::jsonb,
      NOW(),
      NOW()
    );
    v_student_count := v_student_count + 1;
    RAISE NOTICE '✅ تم إضافة: نورة أحمد';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ نورة أحمد موجودة مسبقاً';
  END;

  -- ========================================
  -- الطالبة 2: سارة محمد
  -- ========================================
  BEGIN
    INSERT INTO students (
      school_id,
      teacher_id,
      name,
      grade,
      age,
      color,
      initials,
      parent_phone,
      invite_code,
      archived,
      forms,
      schedule,
      created_at,
      updated_at
    ) VALUES (
      v_school_id,
      v_teacher_id,
      'سارة محمد',
      'الصف الثاني ب',
      8,
      'c-purple',
      'س',
      '0502222222',
      'INV' || floor(random() * 900000 + 100000)::text,
      false,
      '{}'::jsonb,
      '[]'::jsonb,
      NOW(),
      NOW()
    );
    v_student_count := v_student_count + 1;
    RAISE NOTICE '✅ تم إضافة: سارة محمد';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ سارة محمد موجودة مسبقاً';
  END;

  -- ========================================
  -- الطالبة 3: فاطمة علي
  -- ========================================
  BEGIN
    INSERT INTO students (
      school_id,
      teacher_id,
      name,
      grade,
      age,
      color,
      initials,
      parent_phone,
      invite_code,
      archived,
      forms,
      schedule,
      created_at,
      updated_at
    ) VALUES (
      v_school_id,
      v_teacher_id,
      'فاطمة علي',
      'الصف الثالث أ',
      9,
      'c-mint',
      'ف',
      '0503333333',
      'INV' || floor(random() * 900000 + 100000)::text,
      false,
      '{}'::jsonb,
      '[]'::jsonb,
      NOW(),
      NOW()
    );
    v_student_count := v_student_count + 1;
    RAISE NOTICE '✅ تم إضافة: فاطمة علي';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ فاطمة علي موجودة مسبقاً';
  END;

  -- ========================================
  -- الطالبة 4: مريم خالد
  -- ========================================
  BEGIN
    INSERT INTO students (
      school_id,
      teacher_id,
      name,
      grade,
      age,
      color,
      initials,
      parent_phone,
      invite_code,
      archived,
      forms,
      schedule,
      created_at,
      updated_at
    ) VALUES (
      v_school_id,
      v_teacher_id,
      'مريم خالد',
      'روضة ثانية',
      5,
      'c-amber',
      'م',
      '0504444444',
      'INV' || floor(random() * 900000 + 100000)::text,
      false,
      '{}'::jsonb,
      '[]'::jsonb,
      NOW(),
      NOW()
    );
    v_student_count := v_student_count + 1;
    RAISE NOTICE '✅ تم إضافة: مريم خالد';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ مريم خالد موجودة مسبقاً';
  END;

  -- ========================================
  -- الطالبة 5: ريم عبدالله
  -- ========================================
  BEGIN
    INSERT INTO students (
      school_id,
      teacher_id,
      name,
      grade,
      age,
      color,
      initials,
      parent_phone,
      invite_code,
      archived,
      forms,
      schedule,
      created_at,
      updated_at
    ) VALUES (
      v_school_id,
      v_teacher_id,
      'ريم عبدالله',
      'الصف الأول ب',
      7,
      'c-pink',
      'ر',
      '0505555555',
      'INV' || floor(random() * 900000 + 100000)::text,
      false,
      '{}'::jsonb,
      '[]'::jsonb,
      NOW(),
      NOW()
    );
    v_student_count := v_student_count + 1;
    RAISE NOTICE '✅ تم إضافة: ريم عبدالله';
  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE '⚠️ ريم عبدالله موجودة مسبقاً';
  END;

  -- ========================================
  -- رسالة النهائية
  -- ========================================
  
  RAISE NOTICE '════════════════════════════════════════';
  RAISE NOTICE '🎉 تم إضافة % طالبات جديدة!', v_student_count;
  RAISE NOTICE '════════════════════════════════════════';

END $$;

-- ========================================
-- عرض جميع الطالبات
-- ========================================

SELECT 
  '📋 جميع الطالبات المسجلات' as info;

SELECT 
  id,
  name as "الاسم",
  grade as "الصف",
  age as "العمر",
  color as "اللون",
  parent_phone as "جوال ولي الأمر",
  archived as "مؤرشفة",
  created_at as "تاريخ الإضافة"
FROM students
WHERE school_id = (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1)
ORDER BY created_at DESC;

-- عرض العدد الإجمالي
SELECT 
  COUNT(*) as "إجمالي الطالبات"
FROM students
WHERE school_id = (SELECT id FROM schools WHERE name = 'الابتدائية 382' LIMIT 1)
  AND archived = false;

-- ========================================
-- ملاحظات مهمة
-- ========================================

/*

🎉 تم إضافة 5 طالبات تجريبية:

1️⃣ نورة أحمد - الصف الأول أ (7 سنوات) 🔵
2️⃣ سارة محمد - الصف الثاني ب (8 سنوات) 🟣
3️⃣ فاطمة علي - الصف الثالث أ (9 سنوات) 🟢
4️⃣ مريم خالد - روضة ثانية (5 سنوات) 🟡
5️⃣ ريم عبدالله - الصف الأول ب (7 سنوات) 🌸

✅ جميع الطالبات مرئية لجميع المعلمات
✅ تم تعيين معلمة افتراضية لكل طالبة
✅ كل طالبة لها رمز دعوة فريد

────────────────────────────────────────

🔍 للتحقق من الطالبات:

1. سجل دخول كمعلمة
2. اذهب إلى تبويب "الطالبات"
3. يجب أن ترى 5 طالبات (أو أكثر)

────────────────────────────────────────

🗑️ لحذف الطالبات التجريبية:

DELETE FROM students 
WHERE name IN ('نورة أحمد', 'سارة محمد', 'فاطمة علي', 'مريم خالد', 'ريم عبدالله');

────────────────────────────────────────

*/
