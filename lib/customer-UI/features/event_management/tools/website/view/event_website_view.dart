import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_manage_fab.dart';
import 'package:eventak/customer-UI/features/event_management/tools/website/widgets/website_form_dialog.dart';
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch website')),
        );
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

    if (updated == true) {
      setState(() {
        _websiteFuture = _service.fetchWebsiteDetails(widget.eventId);
      });
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

          if (website == null) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              WebsiteStatusCard(
                website: website,
                onOpenUrl: () => _launchURL(website.htmlUrl),
                onUpdate: () => _showUpdateDialog(website),
              ),
              const SizedBox(height: 24),
              const Text(
                "Website Pages",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...website.pages.map((page) => WebsitePageTile(page: page)),
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
          const Text(
            "No Website Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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