
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/services/view/providers_list_view.dart';

// lib/customer-UI/features/home/widgets/service_providers_tabs.dart

class AllServicesTabsView extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final int initialIndex;

  const AllServicesTabsView({
    super.key,
    required this.categories,
    this.initialIndex = 0,
  });

  @override
  State<AllServicesTabsView> createState() => _AllServicesTabsViewState();
}

// lib/customer-UI/features/services/widgets/service_providers_tabs.dart

class _AllServicesTabsViewState extends State<AllServicesTabsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _tabsData; // Local list with "All"

  @override
  void initState() {
    super.initState();
    _tabsData = [
      {'name': 'All', 'id': -1}, // ID -1 "Show Everything"
      ...widget.categories,
    ];

    _tabController = TabController(
      length: _tabsData.length,
      vsync: this,
      initialIndex: widget.initialIndex + 1, 
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services', style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPillTabs(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabsData.map((cat) {
          return ProvidersListView(
            categoryTitle: cat['name'] ?? 'All',
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPillTabs() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabsData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _tabsData[index];
          final bool selected = _tabController.index == index;

          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColor.primary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: selected ? AppColor.primary : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                cat['name'],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}