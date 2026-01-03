import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/data/search_service.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';
import 'package:eventak/customer-UI/features/service_details/view/service_details_view.dart';
import 'package:eventak/customer-UI/features/packages/package_details/view/package_details_view.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SearchService _searchService = SearchService();

  List<SearchResult> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isEmpty) {
        setState(() {
          _results = [];
          _errorMessage = null;
        });
        return;
      }
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _searchService.search(query);

      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll(
          'Exception: ',
          'Something went wrong: ',
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleResultTap(SearchResult item) {
  if (item.type == SearchResultType.service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsView(serviceId: item.id),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageDetailsView(packageId: item.id),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: _results.isEmpty && !_isLoading && _errorMessage == null
                    ? const Center(child: Text("Type to search"))
                    : _results.isEmpty && !_isLoading
                    ? const Center(child: Text("No results found"))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _results[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _handleResultTap(item),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: item.image != null
                                        ? NetworkImage(item.image!)
                                        : null,
                                    child: item.image == null
                                        ? const Icon(Icons.image, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (item.description != null)
                                          Text(
                                            item.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            if (item.rating != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                                  Text(
                                                    item.rating!.toStringAsFixed(1),
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            const Spacer(),
                                            Text(
                                              item.type == SearchResultType.service
                                                  ? 'Service'
                                                  : 'Package',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColor.blueFont,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },

                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
