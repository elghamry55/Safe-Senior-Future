import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'locale_cubit.dart';

class AppTexts {
  static const Map<String, Map<String, String>> _t = {
    'ar': {
      'skip': 'تخطي',
      'start': 'ابدأ الآن',
      'next' : 'التالي',
      'o_title1': 'مرحبًا بك في\nSafe Senior Future',

      'o_sub1':
      'رفيقك الذكي لإدارة صحتك، تذكير بالأدوية، متابعة المواعيد، والتواصل مع عائلتك بكل سهولة وأمان',
      'o_title2': 'لا تفوّت جرعة دوائك',

      'o_sub2':
      'استقبل تنبيهات ذكية في الوقت المناسب مع جدول منظم للأدوية يساعدك على الالتزام بالعلاج دون عناء',
      'o_title3': 'المساعدة بضغطة واحدة',

      'o_sub3':
      'إذا احتجت للمساعدة يمكنك الوصول إلى خدمات الطوارئ أو التواصل مع أفراد العائلة، واستقبل تنبيهات الطوارئ والإشعارات المهمة لحظة بلحظة.',
      'o_title4': 'كل شيء أصبح جاهزًا',

      'o_sub4':
      'لنبدأ رحلتنا معًا.\nأنت لست وحدك؛ نحن هنا من أجلك دائمًا لمتابعة حالتك الصحية والتواصل مع عائلتك في أي وقت.',
      'w_title': 'نظامك المتكامل للرعاية الذكية',
      'w_header': 'من أنت؟',

      'w_subtitle': 'اختر نوع الحساب المناسب لك\nلنقدم لك تجربة مخصصة',

      'w_patient': 'أنا مريض',

      'w_p_desc': 'أريد إدارة أدويتي ومتابعة حالتي الصحية بسهولة.',

      'w_family': 'أنا أحد أفراد العائلة',

      'w_f_desc': 'أريد متابعة صحة أحبائي والاطمئنان عليهم.',
      'w_select': 'حدد نوع الحساب للبدء:',
      'p_title': 'تسجيل جديد',
      'p_welcome': 'مرحباً بك',
      'p_fill': 'الرجاء ملء البيانات التالية بخط واضح',
      'p_name': 'الاسم الثلاثي',
      'p_age': 'العمر بالسنوات',
      'p_dis': 'الأمراض المزمنة (إن وجدت)',
      'p_save': 'حـفـظ والـبـدء',
      'p_login': 'لديك رقم تعريف سابق؟ اضغط هنا',
      'f_title': 'ربط حساب العائلة',
      'f_track': 'متابعة حالة المريض',
      'f_fill': 'قم بإدخال بياناتك وكود المريض ليتم الربط',
      'f_name': 'اسمك الشخصي',
      'f_rel': 'صلة القرابة',
      'f_code': 'كود المريض (PA-xxxx)',
      'f_save': 'تأكيد الربط والمتابعة',
      'd_title': 'لوحة المراقبة',
      'd_welcome': 'أهلاً بك،',
      'd_id': 'كود المريض (اضغط للنسخ)',
      'd_copied': 'تم نسخ كود المريض',
      'd_heart': 'نبض القلب',
      'd_spo2': 'نسبة الأكسجين',
      'd_temp': 'درجة الحرارة',
      'd_med': 'مواعيد الأدوية',
      'd_med_sub': 'اضغط لمتابعة جدولك العلاجي',
      'd_sos': 'نداء استغاثة عاجل',
      'd_menu_med': 'الأدوية والعلاج',
      'd_menu_ent': 'المكتبة والترفيه',
      'd_menu_hist': 'السجلات التاريخية',
      'd_logout': 'تسجيل الخروج',
      'f_dash_title': 'مراقبة المريض',
      'f_dash_meds': 'الأدوية',
      'f_dash_hist': 'السجلات',
      'f_dash_logout': 'تسجيل الخروج',
      'f_dash_logout_msg': 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
      'f_dash_cancel': 'إلغاء',
      'f_dash_exit': 'خروج',
      'f_dash_vitals': 'المؤشرات الحيوية',
      'f_dash_status': 'الحالة العامة',
      'f_dash_alerts': 'سجل الإنذارات',
      'f_dash_no_alerts': 'لا توجد إنذارات مسجلة',
      'f_dash_add_med': 'إضافة جرعة دواء للمريض',
      'f_dash_no_meds': 'لا توجد أدوية حالياً',
      'med_schedule_title': 'جدول الأدوية',
      'med_no_data': 'لا توجد أدوية مسجلة',
      'med_dose': 'الجرعة:',
      'med_time': 'الوقت:',
      'med_edit': 'تعديل البيانات',
      'med_name': 'الاسم',
      'med_cancel': 'إلغاء',
      'med_save': 'حفظ',
      'med_delete_title': 'حذف الدواء',
      'med_delete_msg': 'هل أنت متأكد من حذف',
      'med_delete_confirm': 'حذف',
      'med_add_title': 'إضافة دواء جديد',
      'med_basic_info': 'المعلومات الأساسية',
      'med_name_hint': 'مثال: بنادول',
      'med_dose_hint': 'مثال: قرص واحد',
      'med_alarm_time': 'موعد التنبيه',
      'med_repeat_days': 'أيام التكرار',
      'med_save_btn': 'حفظ وتفعيل الجدول',
      'quran_title': 'المصحف الصوتي',
      'quran_reader': 'ياسر الدوسري',
      'quran_downloading': 'جاري التحميل...',
      'quran_download_title': 'تحميل سورة',
      'quran_download_msg':
      'السورة غير موجودة على جهازك. هل تريد تحميلها الآن لسماعها بدون إنترنت؟',
      'quran_download_btn': 'تحميل',
    },
    'en': {
      'skip': 'Skip',
      'start': 'Get Started',
      'next' : 'next',

      'o_title1': 'Welcome to\nSafe Senior Future',

      'o_sub1':
      'Your smart companion for managing your health, medication reminders, appointments, and staying connected with your family.',
      'o_title2': 'Never Miss Your Medication',

      'o_sub2':
      'Receive smart reminders on time with an organized medication schedule to help you stay on track.',
      'o_title3': 'Help with One Tap',

      'o_sub3':
      'Reach emergency services or contact your family instantly, and receive important emergency alerts and notifications in real time.',
      'o_title4': 'Everything is Ready',

      'o_sub4':
      'Let’s begin our journey together.\nYou are never alone—we are always here to support your health and keep you connected with your family anytime.',
      'w_title': 'Your Integrated Smart Care System',
      'w_select': 'Select account type to start:',
      'w_header': 'Who Are You?',

      'w_subtitle':
      'Choose the account type that suits you\nfor a personalized experience',

      'w_patient': 'I am a Patient',

      'w_p_desc': 'Manage your medications with ease.',

      'w_family': 'I am a Family Member',

      'w_f_desc': 'Monitor your loved ones with ease.',
      'p_title': 'New Registration',
      'p_welcome': 'Welcome',
      'p_fill': 'Please fill in the following details clearly',
      'p_name': 'Full Name',
      'p_age': 'Age in years',
      'p_dis': 'Chronic Diseases (if any)',
      'p_save': 'Save & Start',
      'p_login': 'Already have an ID? Click here',
      'f_title': 'Link Family Account',
      'f_track': 'Monitor Patient Status',
      'f_fill': 'Enter your details and patient ID to link',
      'f_name': 'Your Name',
      'f_rel': 'Relation',
      'f_code': 'Patient ID (PA-xxxx)',
      'f_save': 'Confirm Link & Monitor',
      'd_title': 'Dashboard',
      'd_welcome': 'Welcome,',
      'd_id': 'Patient ID (Tap to copy)',
      'd_copied': 'Patient ID copied',
      'd_heart': 'Heart Rate',
      'd_spo2': 'Oxygen Level',
      'd_temp': 'Temperature',
      'd_med': 'Medications',
      'd_med_sub': 'Tap to view your schedule',
      'd_sos': 'Emergency SOS',
      'd_menu_med': 'Medications & Care',
      'd_menu_ent': 'Entertainment',
      'd_menu_hist': 'Vitals History',
      'd_logout': 'Logout',
      'f_dash_title': 'Patient Monitor',
      'f_dash_meds': 'Medications',
      'f_dash_hist': 'History',
      'f_dash_logout': 'Logout',
      'f_dash_logout_msg': 'Are you sure you want to logout?',
      'f_dash_cancel': 'Cancel',
      'f_dash_exit': 'Logout',
      'f_dash_vitals': 'Vitals',
      'f_dash_status': 'General Status',
      'f_dash_alerts': 'Alerts History',
      'f_dash_no_alerts': 'No alerts recorded',
      'f_dash_add_med': 'Add Patient Medication',
      'f_dash_no_meds': 'No medications currently',
      'med_schedule_title': 'Medication Schedule',
      'med_no_data': 'No medications found',
      'med_dose': 'Dose:',
      'med_time': 'Time:',
      'med_edit': 'Edit Data',
      'med_name': 'Name',
      'med_cancel': 'Cancel',
      'med_save': 'Save',
      'med_delete_title': 'Delete Medication',
      'med_delete_msg': 'Are you sure you want to delete',
      'med_delete_confirm': 'Delete',
      'med_add_title': 'Add New Medication',
      'med_basic_info': 'Basic Information',
      'med_name_hint': 'e.g., Panadol',
      'med_dose_hint': 'e.g., One Pill',
      'med_alarm_time': 'Alarm Time',
      'med_repeat_days': 'Repeat Days',
      'med_save_btn': 'Save & Activate Schedule',
      'quran_title': 'Audio Quran',
      'quran_reader': 'Yasser Al-Dosari',
      'quran_downloading': 'Downloading...',
      'quran_download_title': 'Download Surah',
      'quran_download_msg':
      'This Surah is not on your device. Download it now for offline listening?',
      'quran_download_btn': 'Download',
    },
  };

  static String get(BuildContext context, String key) {
    // context.watch بيخلي الشاشة تتحدث تلقائياً أول ما اللغة تتغير
    final lang = context.watch<LocaleCubit>().state.languageCode;
    return _t[lang]?[key] ?? key;
  }
}
