import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';

abstract class BrowserRemoteDataSource {
  Future<String> downloadFile(String url, String savePath);
  Future<String> extractWebPageText(String url);
}

class BrowserRemoteDataSourceImpl implements BrowserRemoteDataSource {
  final Dio dio;

  BrowserRemoteDataSourceImpl(this.dio);

  @override
  Future<String> downloadFile(String url, String savePath) async {
    try {
      await dio.download(url, savePath);
      return savePath;
    } catch (e) {
      throw ServerException('Failed to download file: $e');
    }
  }

  @override
  Future<String> extractWebPageText(String url) async {
    try {
      final response = await dio.get(url);
      // Basic HTML text extraction (can be enhanced with html package)
      String html = response.data.toString();
      
      // Remove script and style tags
      html = html.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '');
      html = html.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
      
      // Remove HTML tags
      html = html.replaceAll(RegExp(r'<[^>]+>'), ' ');
      
      // Clean up whitespace
      html = html.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      return html;
    } catch (e) {
      throw ServerException('Failed to extract web page text: $e');
    }
  }
}
