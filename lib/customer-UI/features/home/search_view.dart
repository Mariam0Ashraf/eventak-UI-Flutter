import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Dummy
  final List<String> _allResults = [
    'Wedding Package',
    'Birthday Party',
    'Graduation Event',
    'Catering Service',
    'Photographer',
    'Venue Rental',
    'Decor Services',
  ];

  List<String> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    // Focus search bar when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
    
    _filteredResults = List.from(_allResults);

    _searchController.addListener(_filterResults);
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResults = List.from(_allResults);
      } else {
        _filteredResults = _allResults
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.beige,
      appBar: AppBar(
        backgroundColor: AppColor.beige,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search, color: AppColor.blueFont),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), 
        child: _filteredResults.isEmpty
            ? const Center(child: Text("No results found"))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _filteredResults[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColor.blueFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
