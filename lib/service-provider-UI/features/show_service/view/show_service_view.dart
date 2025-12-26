import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_api.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/edit_service_view.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/service_reviews_view.dart';

class ShowServicePage extends StatefulWidget {
  final MyService service;

  const ShowServicePage({super.key, required this.service});

  @override
  State<ShowServicePage> createState() => _ShowServicePageState();
}

class _ShowServicePageState extends State<ShowServicePage> {
  final MyServicesService _api = MyServicesService();

  late MyService _service;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final updated = await _api.getService(_service.id);
      if (!mounted) return;
      setState(() => _service = updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onEdit() async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditServiceView(service: _service)),
    );

    if (changed == true) {
      await _refresh();
    }
  }

  Future<void> _onDelete() async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Delete service?'),
            content: const Text(
              'Are you sure you want to delete this service?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      setState(() => _loading = true);
      await _api.deleteService(_service.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _service;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.blueFont),
        title: Text(
          'Service Details',
          style: TextStyle(
            color: AppColor.blueFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: AppColor.blueFont,
                    side: BorderSide(
                      color: AppColor.blueFont.withOpacity(0.35),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) ...[
              const SizedBox(height: 10),
              _ErrorCard(message: _error!),
            ],

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: TextStyle(
                      color: AppColor.blueFont,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (s.categoryId != null)
                        _Pill(
                          text: 'Category #${s.categoryId}',
                          bg: AppColor.background,
                          fg: AppColor.blueFont,
                          icon: Icons.category,
                        ),
                      _Pill(
                        text: s.isActive ? 'Active' : 'Inactive',
                        bg: s.isActive
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        fg: s.isActive ? Colors.green : Colors.red,
                        icon: s.isActive ? Icons.check_circle : Icons.cancel,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (s.location != null && s.location!.trim().isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColor.blueFont.withOpacity(0.75),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.location!,
                            style: TextStyle(
                              color: AppColor.blueFont.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (s.basePrice != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${s.basePrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (s.priceUnit ?? '').isEmpty ? '' : s.priceUnit!,
                            style: TextStyle(
                              color: AppColor.blueFont.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Description Card
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      color: AppColor.blueFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (s.description?.trim().isNotEmpty ?? false)
                        ? s.description!
                        : 'No description provided.',
                    style: TextStyle(
                      color: AppColor.blueFont.withOpacity(0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Reviews Card
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      color: AppColor.blueFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ServiceReviewsSection(
                    serviceId: s.id,
                    useDummyIfFailed: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
