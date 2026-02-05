import 'package:flutter/material.dart';
import '../data/event_website_model.dart';

class WebsiteStatusCard extends StatelessWidget {
  final EventWebsite website;
  final VoidCallback onOpenUrl;
  final VoidCallback onUpdate;
  final VoidCallback onSettings; // New callback for form-data settings
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  const WebsiteStatusCard({
    super.key,
    required this.website,
    required this.onOpenUrl,
    required this.onUpdate,
    required this.onTogglePublish,
    required this.onDelete,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPublished = website.isPublished;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Website Status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Quick Settings Button (Primary Color & Meta Title)
                  IconButton(
                    onPressed: onSettings,
                    icon: const Icon(Icons.settings_outlined, size: 20, color: Colors.blueGrey),
                    tooltip: "Quick Settings",
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    tooltip: "Delete Website",
                  ),
                  IconButton(
                    onPressed: onUpdate,
                    icon: const Icon(Icons.palette_outlined, size: 20, color: Colors.blue),
                    tooltip: "Update Design",
                  ),
                  const SizedBox(width: 4),
                  _buildStatusBadge(isPublished),
                ],
              )
            ],
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link, color: Colors.blue),
            title: const Text("Public URL", style: TextStyle(fontSize: 13)),
            subtitle: Text(
              website.slug,
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
            onTap: onOpenUrl,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTogglePublish,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isPublished ? Colors.red : Colors.green),
                foregroundColor: isPublished ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(isPublished ? Icons.cloud_off : Icons.cloud_upload, size: 18),
              label: Text(
                isPublished ? "Unpublish Website" : "Publish Website",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPublished ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPublished ? "Published" : "Draft",
        style: TextStyle(
          color: isPublished ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
class WebsitePageTile extends StatelessWidget {
  final WebsitePage page;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WebsitePageTile({
    super.key,
    required this.page,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: const Icon(Icons.reorder, color: Colors.grey),
        title: Text(page.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("/${page.slug}", style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              page.showInMenu ? Icons.check_circle : Icons.visibility_off,
              color: page.showInMenu ? Colors.green : Colors.grey,
              size: 18,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: onEdit,
              tooltip: "Edit Page",
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
              tooltip: "Delete Page",
            ),
          ],
        ),
      ),
    );
  }
}