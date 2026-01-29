import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_manage_fab.dart';
import 'package:eventak/customer-UI/features/event_management/tools/timeline/widgets/create_timeline_dialog.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/timeline_service.dart';
import '../data/timeline_model.dart';
import '../widgets/timeline_list_tile.dart';

class TimelineView extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const TimelineView({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final TimelineService _service = TimelineService();
  List<TimelineItem> _currentItems = [];
  late Future<List<TimelineItem>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    _refreshTimeline();
  }

  void _refreshTimeline() {
    setState(() {
      _timelineFuture = _service.fetchTimeline(widget.eventId).then((value) {
        setState(() {
          _currentItems = value;
        });
        return value;
      });
    });
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _currentItems.removeAt(oldIndex);
      _currentItems.insert(newIndex, item);
    });

    final orderedIds = _currentItems.map((e) => e.id).toList();
    final success = await _service.reorderTimeline(widget.eventId, orderedIds);

    if (!success && mounted) {
      _refreshTimeline();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save new order')),
      );
    }
  }

  Future<void> _handleDelete(int timelineId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to remove this timeline item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteTimelineItem(widget.eventId, timelineId);
      if (success && mounted) _refreshTimeline();
    }
  }

  Future<void> _handlePrint() async {
    try {
      final data = await _service.getPrintableTimeline(widget.eventId);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          pdf.addPage(
            pw.MultiPage(
              pageFormat: format,
              build: (pw.Context context) => [
                pw.Text('Event Timeline Report',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Event: ${widget.eventTitle}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                pw.Text('Generated at: ${data['generated_at']}'),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Time', 'End Time', 'Duration', 'Title', 'Description'],
                  data: List<List<dynamic>>.from(
                    data['timeline_items'].map((item) => [
                          item['time'],
                          item['end_time'],
                          item['duration'],
                          item['title'],
                          item['description'],
                        ]),
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Items: ${data['summary']['total_items']}'),
                      pw.Text(
                        'Total Duration: ${data['summary']['total_duration_minutes']} min',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          return pdf.save();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate PDF')),
        );
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => CreateTimelineDialog(
        eventId: widget.eventId,
        lastOrder: _currentItems.length,
        onSuccess: _refreshTimeline,
      ),
    );
  }

  void _showUpdateDialog(TimelineItem item) {
    showDialog(
      context: context,
      builder: (_) => CreateTimelineDialog(
        eventId: widget.eventId,
        lastOrder: _currentItems.length,
        timeline: item,
        onSuccess: _refreshTimeline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: EventManagementFab(
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
        activeIndex: 2,
      ),
      appBar: AppBar(
        title: const Text('Event Timeline'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.blueFont,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: _handlePrint,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      side: BorderSide(color: AppColor.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Print', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          // --- List View ---
          Expanded(
            child: FutureBuilder<List<TimelineItem>>(
              future: _timelineFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _currentItems.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_currentItems.isEmpty) {
                  return const Center(child: Text('No timeline items found.'));
                }

                return Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: _currentItems.length,
                    onReorder: _onReorder,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemBuilder: (context, index) {
                      final item = _currentItems[index];
                      return TimelineListTile(
                        key: ValueKey(item.id),
                        timeline: item,
                        index: index,
                        onDelete: () => _handleDelete(item.id),
                        onEdit: () => _showUpdateDialog(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}