import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_manage_fab.dart';
import 'package:eventak/customer-UI/features/event_management/tools/website/widgets/website_form_dialog.dart';
import 'package:eventak/customer-UI/features/event_management/tools/website/widgets/page_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/event_website_model.dart';
import '../data/event_website_service.dart';
import '../widgets/website_management_widgets.dart';

class EventWebsiteView extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventWebsiteView({super.key, required this.eventId, required this.eventTitle});

  @override
  State<EventWebsiteView> createState() => _EventWebsiteViewState();
}

class _EventWebsiteViewState extends State<EventWebsiteView> {
  final EventWebsiteService _service = EventWebsiteService();
  late Future<EventWebsite?> _websiteFuture;

  @override
  void initState() {
    super.initState();
    _websiteFuture = _service.fetchWebsiteDetails(widget.eventId);
  }

  void _refreshData() {
    setState(() {
      _websiteFuture = _service.fetchWebsiteDetails(widget.eventId);
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
       
      }
    }
  }

  void _showUpdateDialog(EventWebsite? website) async {
    bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => WebsiteFormDialog(
        eventId: widget.eventId,
        existingWebsite: website,
      ),
    );
    if (updated == true) _refreshData();
  }

  void _addPage() async {
    bool? created = await showDialog<bool>(
      context: context,
      builder: (context) => PageFormDialog(eventId: widget.eventId),
    );
    if (created == true) _refreshData();
  }

  void _editPage(WebsitePage page) async {
    bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => PageFormDialog(
        eventId: widget.eventId,
        existingPage: page,
      ),
    );
    if (updated == true) _refreshData();
  }

  Future<void> _handleTogglePublish(int eventId) async {
    try {
      final bool newState = await _service.togglePublishStatus(eventId);
      if (mounted) {
        _refreshData();
        
      }
    } catch (e) {
      if (mounted) {
       
      }
    }
  }

  Future<void> _handleDeleteWebsite() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Website"),
        content: const Text("Are you sure you want to delete this website? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteWebsite(widget.eventId);
        if (mounted) {
          _refreshData();
         
        }
      } catch (e) {
        if (mounted) {
         
        }
      }
    }
  }

  Future<void> _handleDeletePage(int pageId, String pageTitle) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Page"),
        content: Text("Are you sure you want to delete the '$pageTitle' page?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteWebsitePage(widget.eventId, pageId);
        _refreshData();
        if (mounted) {
          
        }
      } catch (e) {
        if (mounted) {
          
        }
      }
    }
  }

  Future<void> _handleReorder(List<WebsitePage> pages, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;

    setState(() {
      final WebsitePage item = pages.removeAt(oldIndex);
      pages.insert(newIndex, item);
    });

    List<Map<String, int>> pageOrders = [];
    for (int i = 0; i < pages.length; i++) {
      pageOrders.add({"id": pages[i].id, "order": i + 1});
    }

    try {
      await _service.reorderWebsitePages(widget.eventId, pageOrders);
    } catch (e) {
      _refreshData();
      if (mounted) {
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Website Management", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: EventManagementFab(
        eventId: widget.eventId,
        activeIndex: 5,
        eventTitle: widget.eventTitle,
      ),
      body: FutureBuilder<EventWebsite?>(
        future: _websiteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final website = snapshot.data;
          if (website == null) return _buildEmptyState();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              WebsiteStatusCard(
                website: website,
                onOpenUrl: () => _launchURL(website.htmlUrl),
                onUpdate: () => _showUpdateDialog(website),
                onTogglePublish: () => _handleTogglePublish(widget.eventId),
                onDelete: _handleDeleteWebsite,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Website Pages",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _addPage,
                    icon: Icon(Icons.add_circle, color: AppColor.primary),
                    tooltip: "Add New Page",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (website.pages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No pages added yet.", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false, 
                  onReorder: (old, newVal) => _handleReorder(website.pages, old, newVal),
                  children: website.pages.map((page) => ReorderableDragStartListener(
                    index: website.pages.indexOf(page),
                    key: ValueKey(page.id),
                    child: WebsitePageTile(
                      page: page,
                      onDelete: () => _handleDeletePage(page.id, page.title),
                      onEdit: () => _editPage(page),
                    ),
                  )).toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.web_asset_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No Website Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              "It looks like you haven't created a website for this event yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showUpdateDialog(null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Create Website", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}