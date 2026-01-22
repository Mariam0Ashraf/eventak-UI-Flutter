import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';

class EditServiceGallerySection extends StatelessWidget {
  final Uint8List? thumbnailBytes;
  final String? existingThumbnailUrl;
  final List<GalleryMedia> existingGallery;
  final List<Uint8List> newGalleryBytes;
  final VoidCallback onPickThumbnail;
  final VoidCallback onPickGallery;
  final Function(int mediaId) onRemoveExisting;
  final Function(int index) onRemoveNew;

  const EditServiceGallerySection({
    super.key,
    this.thumbnailBytes,
    this.existingThumbnailUrl,
    required this.existingGallery,
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
        const Text("Thumbnail",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildThumbnailPicker(),
        const SizedBox(height: 20),
        const Text("Gallery Images",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    child:
                        Image.network(existingThumbnailUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.add_a_photo, color: Colors.grey))
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
          ...existingGallery.map((media) => _galleryItem(media.url, true, mediaId: media.id)),
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
                child: const Icon(Icons.add_photo_alternate_outlined,
                    color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _galleryItem(dynamic source, bool isExisting, {int? index, int? mediaId}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isExisting
                ? Image.network(source as String,
                    width: 100, height: 100, fit: BoxFit.cover)
                : Image.memory(source as Uint8List,
                    width: 100, height: 100, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              if (isExisting) {
                if (mediaId != null) onRemoveExisting(mediaId);
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
      
      int? selectedIdForThisLevel =
          i < selectedAreaIds.length ? selectedAreaIds[i] : null;
          
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
          var selectedNode = currentLevelItems
              .firstWhere((item) => item['id'] == selectedIdForThisLevel);
          currentLevelItems =
              List<Map<String, dynamic>>.from(selectedNode['children'] ?? []);
        } catch (e) {
          currentLevelItems = [];
        }
      } else {
        break;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: dropdownWidgets
    );
  }
}

class AvailableAreaMultiSelect extends StatelessWidget {
  final List<Map<String, dynamic>> areaTree;
  final List<List<int?>> selectedAvailableAreaPaths;
  final Function(List<List<int?>> newPaths) onPathsChanged;

  const AvailableAreaMultiSelect({
    super.key,
    required this.areaTree,
    required this.selectedAvailableAreaPaths,
    required this.onPathsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...selectedAvailableAreaPaths.asMap().entries.map((entry) {
          int index = entry.key;
          List<int?> path = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Area Selection ${index + 1}"),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          List<List<int?>> newPaths = List.from(selectedAvailableAreaPaths);
                          newPaths.removeAt(index);
                          onPathsChanged(newPaths);
                        },
                      ),
                    ],
                  ),
                  _buildPathDropdowns(index, path),
                ],
              ),
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: () {
            List<List<int?>> newPaths = List.from(selectedAvailableAreaPaths);
            newPaths.add([]);
            onPathsChanged(newPaths);
          },
          icon: const Icon(Icons.add_location_alt),
          label: const Text("Add Another Area"),
        ),
      ],
    );
  }

  Widget _buildPathDropdowns(int pathIndex, List<int?> path) {
    List<Widget> dropdowns = [];
    List<Map<String, dynamic>> currentItems = areaTree;

    for (int i = 0; i <= path.length; i++) {
      if (currentItems.isEmpty) break;
      int? selectedId = i < path.length ? path[i] : null;
      String typeName = currentItems.first['type'] ?? 'Area';

      dropdowns.add(
        CustomDropdownField<int>(
          label: "${typeName[0].toUpperCase() + typeName.substring(1)} ${i > 0 ? '(Optional)' : ''}",
          value: selectedId,
          hintText: 'Select $typeName',
          validator: i == 0 ? (val) => val == null ? 'Country is required' : null : null,
          items: currentItems.map((area) {
            return DropdownMenuItem<int>(value: area['id'], child: Text(area['name']));
          }).toList(),
          onChanged: (val) {
            List<List<int?>> allPaths = List.from(selectedAvailableAreaPaths);
            List<int?> newPath = i < path.length ? path.sublist(0, i) : List<int?>.from(path);
            if (val != null) newPath.add(val);
            allPaths[pathIndex] = newPath;
            onPathsChanged(allPaths);
          },
        ),
      );

      if (selectedId != null) {
        try {
          var node = currentItems.firstWhere((item) => item['id'] == selectedId);
          currentItems = List<Map<String, dynamic>>.from(node['children'] ?? []);
        } catch (e) {
          currentItems = [];
        }
      } else {
        break;
      }
    }
    return Column(children: dropdowns);
  }
}