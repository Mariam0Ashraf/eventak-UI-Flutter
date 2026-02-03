import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import '../data/gallery_model.dart';

class GalleryService {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token')?.replaceAll('"', '') ?? '';
  }

  Future<List<GalleryItem>> getGallery(int eventId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/gallery'),
      headers: {'Authorization': 'Bearer ${await _getToken()}'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => GalleryItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load gallery');
  }

  Future<GalleryItem> uploadItem({
    required int eventId,
    required dynamic file, 
    required Uint8List bytes, 
    required String title,
    String? description,
    bool isFeatured = false,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.baseUrl}/events/$eventId/gallery'));
    request.headers['Authorization'] = 'Bearer ${await _getToken()}';
    request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    request.fields['is_featured'] = isFeatured ? "1" : "0";

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'upload.${file.path.split('.').last}',
      contentType: MediaType(file.path.endsWith(".mp4") ? 'video' : 'image', file.path.split('.').last),
    ));

    var response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return GalleryItem.fromJson(json.decode(response.body)['data']);
    }
    throw Exception('Upload failed');
  }

  Future<void> updateItem({
    required int eventId,
    required int itemId,
    required String title,
    required bool isFeatured,
    required int order,
  }) async {
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/gallery/$itemId'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "title": title,
        "is_featured": isFeatured,
        "order": order,
      }),
    );
  }

  Future<void> deleteItem(int eventId, int itemId) async {
    await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/gallery/$itemId'),
      headers: {'Authorization': 'Bearer ${await _getToken()}'},
    );
  }

  Future<void> updateOrder(int eventId, List<GalleryItem> items) async {
    final List<Map<String, dynamic>> reorderList = items.asMap().entries.map((entry) {
      return {
        "id": entry.value.id,
        "order": entry.key + 1, 
      };
    }).toList();

    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/gallery/reorder'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'items': reorderList}),
    );
  }
}