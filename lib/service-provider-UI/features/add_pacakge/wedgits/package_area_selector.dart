import 'package:flutter/material.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class AvailableAreasSection extends StatelessWidget {
  final List<Map<String, dynamic>> areaTree;
  final List<List<int?>> availableAreaPaths;
  final Function(List<List<int?>>) onUpdate;

  const AvailableAreasSection({
    super.key,
    required this.areaTree,
    required this.availableAreaPaths,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableAreaPaths.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Area ${index + 1}"),
                        if (availableAreaPaths.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final newPaths = List<List<int?>>.from(availableAreaPaths);
                              newPaths.removeAt(index);
                              onUpdate(newPaths);
                            },
                          )
                      ],
                    ),
                    _buildAreaDropdowns(index),
                  ],
                ),
              ),
            );
          },
        ),
        TextButton.icon(
          onPressed: () {
            final newPaths = List<List<int?>>.from(availableAreaPaths)..add([]);
            onUpdate(newPaths);
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Another Available Area"),
        ),
      ],
    );
  }

  Widget _buildAreaDropdowns(int pathIndex) {
    List<int?> path = availableAreaPaths[pathIndex];
    List<Widget> widgets = [];
    List<Map<String, dynamic>> currentItems = areaTree;

    for (int i = 0; i <= path.length; i++) {
      if (currentItems.isEmpty) break;
      int? selectedId = i < path.length ? path[i] : null;
      String typeName = currentItems.first['type'] ?? 'Area';

      widgets.add(
        CustomDropdownField<int>(
          label: "${typeName[0].toUpperCase() + typeName.substring(1)} ${i > 0 ? '(Optional)' : ''}",
          value: selectedId,
          hintText: 'Select $typeName',
          validator: i == 0 ? (val) => val == null ? 'Country is required' : null : null,
          items: currentItems.map((area) => DropdownMenuItem<int>(value: area['id'], child: Text(area['name']))).toList(),
          onChanged: (val) {
            List<List<int?>> newPaths = List<List<int?>>.from(availableAreaPaths);
            List<int?> newPath = i < path.length ? path.sublist(0, i) : List<int?>.from(path);
            if (val != null) newPath.add(val);
            newPaths[pathIndex] = newPath;
            onUpdate(newPaths);
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
    return Column(children: widgets);
  }
}