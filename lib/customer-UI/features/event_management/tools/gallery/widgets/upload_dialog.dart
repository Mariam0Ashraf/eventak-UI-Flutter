import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import '../data/gallery_service.dart';

class UploadGalleryDialog extends StatefulWidget {
  final int eventId;
  final VoidCallback onSuccess;

  const UploadGalleryDialog({
    super.key,
    required this.eventId,
    required this.onSuccess,
  });

  @override
  State<UploadGalleryDialog> createState() => _UploadGalleryDialogState();
}

class _UploadGalleryDialogState extends State<UploadGalleryDialog> {
  final GalleryService _service = GalleryService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  VideoPlayerController? _videoPreviewController;
  XFile? _selectedXFile;
  Uint8List? _webBytes; 
  bool _isUploading = false;
  bool _isFeatured = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _videoPreviewController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    
    final String? source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Pick Image"),
              onTap: () => Navigator.pop(ctx, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text("Pick Video"),
              onTap: () => Navigator.pop(ctx, 'video'),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? file = source == 'image' 
        ? await picker.pickImage(source: ImageSource.gallery)
        : await picker.pickVideo(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();
      
      if (source == 'video' || file.name.toLowerCase().endsWith('.mp4')) {
        await _videoPreviewController?.dispose();
        
        final controller = VideoPlayerController.file(File(file.path));
        
        try {
          await controller.initialize();
          setState(() {
            _videoPreviewController = controller;
            _selectedXFile = file;
            _webBytes = bytes;
          });
        } catch (e) {
          debugPrint("Video init error: $e");
        }
      } else {
        await _videoPreviewController?.dispose();
        setState(() {
          _videoPreviewController = null;
          _selectedXFile = file;
          _webBytes = bytes;
        });
      }
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedXFile == null || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file and enter a title")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _service.uploadItem(
        eventId: widget.eventId,
        file: _selectedXFile!,
        bytes: _webBytes!, 
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        isFeatured: _isFeatured,
      );

      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload to Gallery",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: _pickMedia,
              child: Container(
                width: double.infinity,
                height: 200, 
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _webBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: 40, color: AppColor.primary),
                          const SizedBox(height: 8),
                          const Text("Tap to select Image or Video",
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildPreview(),
                      ),
              ),
            ),

            const SizedBox(height: 16),
            CustomTextField(controller: _titleController, label: "Title*"),
            CustomTextField(controller: _descController, label: "Description (Optional)"),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Featured Item", style: TextStyle(fontSize: 14)),
              value: _isFeatured,
              activeColor: AppColor.primary,
              onChanged: (val) => setState(() => _isFeatured = val),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _handleUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload Media",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedXFile!.name.toLowerCase().endsWith('.mp4')) {
      if (_videoPreviewController != null && _videoPreviewController!.value.isInitialized) {
        return Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPreviewController!.value.size.width,
                height: _videoPreviewController!.value.size.height,
                child: VideoPlayer(_videoPreviewController!),
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
          ],
        );
      }
      return const Center(child: CircularProgressIndicator());
    } else {
      return Image.memory(_webBytes!, fit: BoxFit.cover);
    }
  }
}