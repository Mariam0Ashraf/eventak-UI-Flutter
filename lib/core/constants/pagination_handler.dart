import 'package:flutter/material.dart';

class PaginationHandler<T> {
  final Future<List<T>> Function(int page) fetchData;
  final ValueNotifier<List<T>> dataNotifier = ValueNotifier<List<T>>([]);
  
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMore = true;

  PaginationHandler({required this.fetchData});

  bool get isFetching => _isFetching;
  bool get hasMore => _hasMore;

  Future<void> fetchNextPage() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    try {
      final newData = await fetchData(_currentPage);
      
      if (newData.isEmpty) {
        _hasMore = false;
      } else {
        dataNotifier.value = [...dataNotifier.value, ...newData];
        _currentPage++;
        if (newData.length < 15) _hasMore = false;
      }
    } catch (e) {
      debugPrint("Pagination Error: $e");
    } finally {
      _isFetching = false;
    }
  }

  void reset() {
    _currentPage = 1;
    _hasMore = true;
    _isFetching = false;
    dataNotifier.value = [];
  }

  void dispose() {
    dataNotifier.dispose();
  }
}