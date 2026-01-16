import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class EditServiceGallerySection extends StatelessWidget {
  final Uint8List? thumbnailBytes;
  final String? existingThumbnailUrl;
  final List<String> existingGalleryUrls;
  final List<Uint8List> newGalleryBytes;
  final VoidCallback onPickThumbnail;
  final VoidCallback onPickGallery;
  final Function(String url) onRemoveExisting;
  final Function(int index) onRemoveNew;

  const EditServiceGallerySection({
    super.key,
    this.thumbnailBytes,
    this.existingThumbnailUrl,
    required this.existingGalleryUrls,
    required this.newGalleryBytes,
    required this.onPickThumbnail,
    required this.onPickGallery,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thumbnail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildThumbnailPicker(),
        const SizedBox(height: 20),
        const Text("Gallery Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildGalleryManager(),
      ],
    );
  }

  Widget _buildThumbnailPicker() {
    return InkWell(
      onTap: onPickThumbnail,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: thumbnailBytes == null
            ? (existingThumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(existingThumbnailUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.add_a_photo))
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(thumbnailBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildGalleryManager() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...existingGalleryUrls.map((url) => _galleryItem(url, true)),
          ...newGalleryBytes.asMap().entries.map(
                (entry) => _galleryItem(entry.value, false, index: entry.key),
              ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: onPickGallery,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _galleryItem(dynamic source, bool isExisting, {int? index}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isExisting
                ? Image.network(source as String, width: 100, height: 100, fit: BoxFit.cover)
                : Image.memory(source as Uint8List, width: 100, height: 100, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              if (isExisting) {
                onRemoveExisting(source as String);
              } else if (index != null) {
                onRemoveNew(index);
              }
            },
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}

class EditServiceAreaDropdowns extends StatelessWidget {
  final List<Map<String, dynamic>> areaTree;
  final List<int?> selectedAreaIds;
  final Function(List<int?> newPath) onAreaChanged;

  const EditServiceAreaDropdowns({
    super.key,
    required this.areaTree,
    required this.selectedAreaIds,
    required this.onAreaChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (areaTree.isEmpty) return const SizedBox.shrink();
    List<Widget> dropdownWidgets = [];
    List<Map<String, dynamic>> currentLevelItems = areaTree;

    for (int i = 0; i <= selectedAreaIds.length; i++) {
      if (currentLevelItems.isEmpty) break;
      int? selectedIdForThisLevel = i < selectedAreaIds.length ? selectedAreaIds[i] : null;
      String typeName = currentLevelItems.first['type'] ?? 'Area';

      dropdownWidgets.add(
        CustomDropdownField<int>(
          label: typeName[0].toUpperCase() + typeName.substring(1),
          value: selectedIdForThisLevel,
          hintText: 'Select $typeName',
          items: currentLevelItems.map((area) {
            return DropdownMenuItem<int>(
              value: area['id'],
              child: Text(area['name']),
            );
          }).toList(),
          onChanged: (val) {
            List<int?> newPath = i < selectedAreaIds.length 
                ? selectedAreaIds.sublist(0, i) 
                : List<int?>.from(selectedAreaIds);
            newPath.add(val);
            onAreaChanged(newPath);
          },
        ),
      );

      if (selectedIdForThisLevel != null) {
        try {
          var selectedNode = currentLevelItems.firstWhere((item) => item['id'] == selectedIdForThisLevel);
          currentLevelItems = List<Map<String, dynamic>>.from(selectedNode['children'] ?? []);
        } catch (e) {
          currentLevelItems = [];
        }
      } else {
        break;
      }
    }
    return Column(children: dropdownWidgets);
  }
}