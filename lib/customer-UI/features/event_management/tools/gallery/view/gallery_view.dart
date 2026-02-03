import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_manage_fab.dart';
import 'package:eventak/customer-UI/features/event_management/tools/gallery/widgets/upload_dialog.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/gallery_model.dart';
import '../data/gallery_service.dart';
import '../widgets/gallery_item_card.dart';

class EventGalleryView extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventGalleryView({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<EventGalleryView> createState() => _EventGalleryViewState();
}

class _EventGalleryViewState extends State<EventGalleryView> {
  final GalleryService _service = GalleryService();

  List<GalleryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    try {
      final items = await _service.getGallery(widget.eventId);
      if (!mounted) return;

      setState(() {
        _items = items..sort((a, b) => a.order.compareTo(b.order));
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
  setState(() {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
  });
  
  _service.updateOrder(widget.eventId, _items);
}

  Future<void> _openUploadDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => UploadGalleryDialog(
        eventId: widget.eventId,
        onSuccess: () {}, 
      ),
    );

    if (mounted) {
      _fetchGallery();
    }
  }

  Future<void> _deleteItem(GalleryItem item) async {
    await _service.deleteItem(widget.eventId, item.id);
    if (mounted) {
      _fetchGallery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: Text(
          "${widget.eventTitle} Gallery",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColor.primary,
            ),
            onPressed: _openUploadDialog,
          ),
        ],
      ),
      floatingActionButton: EventManagementFab(
        eventId: widget.eventId,
        activeIndex: 4,
        eventTitle: widget.eventTitle,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text(
                    "No media added yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ReorderableListView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
  itemCount: _items.length,
  onReorder: _onReorder,
  itemBuilder: (context, index) {
    final item = _items[index];
    return GalleryItemCard(
      key: ValueKey(item.id),
      item: item,
      onDelete: () => _deleteItem(item),
      onEdit: () => _showEditDialog(item), 
    );
  },
),
    );
  }
  void _showEditDialog(GalleryItem item) {
  final titleController = TextEditingController(text: item.title);
  bool isFeatured = item.isFeatured;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => AlertDialog(
        title: const Text("Edit Gallery Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                hintText: "Enter a new title",
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Featured Item"),
              subtitle: const Text("Show this in the event highlights"),
              value: isFeatured,
              activeColor: AppColor.primary,
              onChanged: (val) => setModalState(() => isFeatured = val),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            onPressed: () async {
              try {
                await _service.updateItem(
                  eventId: widget.eventId,
                  itemId: item.id,
                  title: titleController.text.trim(),
                  isFeatured: isFeatured,
                  order: item.order,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  _fetchGallery(); 
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update: $e")),
                );
              }
            },
            child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
}
