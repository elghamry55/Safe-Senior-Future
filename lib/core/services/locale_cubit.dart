import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ar')) {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'ar';
    emit(Locale(lang));
  }

  void toggleLanguage() async {
    final isArabic = state.languageCode == 'ar';
    final newLocale = Locale(isArabic ? 'en' : 'ar');
    emit(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', newLocale.languageCode);
  }
}