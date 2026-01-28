import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_manage_fab.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/budget_service.dart';
import '../data/budget_model.dart';
import '../widgets/budget_list_tile.dart';
import '../widgets/create_budget_dialog.dart';
import '../widgets/record_payment_dialog.dart';
import '../widgets/budget_summary_card.dart';

class BudgetView extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const BudgetView({
    super.key, 
    required this.eventId, 
    required this.eventTitle,
  });

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  final BudgetService _service = BudgetService();
  List<BudgetItem> _items = [];
  Map<String, dynamic>? _summaryData;
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _refreshBudget();
  }

  void _refreshBudget() {
    setState(() {
      _dataFuture = Future.wait([
        _service.fetchBudget(widget.eventId),
        _service.fetchBudgetSummary(widget.eventId),
      ]).then((results) {
        _items = results[0] as List<BudgetItem>;
        _summaryData = results[1] as Map<String, dynamic>;
        return results;
      });
    });
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateBudgetItemDialog(
        eventId: widget.eventId,
        onSuccess: _refreshBudget,
      ),
    );
  }

  void _showUpdateDialog(BudgetItem item) {
    showDialog(
      context: context,
      builder: (context) => CreateBudgetItemDialog(
        eventId: widget.eventId,
        item: item,
        onSuccess: _refreshBudget,
      ),
    );
  }

  void _showPaymentDialog(BudgetItem item) {
    showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        eventId: widget.eventId,
        item: item,
        onSuccess: _refreshBudget,
      ),
    );
  }

  Future<void> _handleDelete(int itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to remove this from your budget?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteBudgetItem(widget.eventId, itemId);
      if (success && mounted) _refreshBudget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      floatingActionButton: EventManagementFab(
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
        activeIndex: 3, 
      ),
      appBar: AppBar(
        title: const Text('Budget Management'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.blueFont,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshBudget(),
            child: CustomScrollView(
              slivers: [
                if (_summaryData != null)
                  SliverToBoxAdapter(
                    child: BudgetSummaryCard(summary: _summaryData!),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Line Items",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: _showCreateDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Create', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No budget items were added')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _items[index];
                          return BudgetListTile(
                            item: item,
                            onDelete: () => _handleDelete(item.id),
                            onEdit: () => _showUpdateDialog(item),
                            onPay: () => _showPaymentDialog(item),
                          );
                        },
                        childCount: _items.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}