import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class EntertainmentRepository {
  final Dio _dio = Dio();

  // الحصول على المسار المحلي
  Future<String> getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  }

  // قراءة محتوى الكتب من الـ Assets
  Future<String> loadBookContent() async {
    return await rootBundle.loadString('assets/book_content.txt');
  }

  // فحص ذكي للملفات المحلية (لتفادي الملفات التالفة اللي حجمها صغير)
  Future<bool> isLocalFileValid(String path, {int minSizeKb = 50}) async {
    File file = File(path);
    if (await file.exists()) {
      int fileSize = await file.length();
      if (fileSize < minSizeKb * 1024) {
        await file.delete(); // حذف الملف التالف
        return false;
      }
      return true;
    }
    return false;
  }

  // تحميل الملفات من الإنترنت
  Future<void> downloadFile({
    required String url,
    required String savePath,
    required Function(int, int) onReceiveProgress,
  }) async {
    await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
  }
}