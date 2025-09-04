import 'package:flutter_ecommerce/model/product_model.dart';

class PaginationController {
  int _currentPage = 1;
  int _itemsPerPage = 10;
  List<ProductModel> _items = [];
  List<ProductModel> _displayedItems = [];
  int _totalPages = 1;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalPages => _totalPages;
  List<ProductModel> get displayedItems => List.unmodifiable(_displayedItems);
  int get totalItems => _items.length;

  void Function()? onPageChanged;

  void updateItems(List<ProductModel> items) {
    _items = items;
    _updatePagination();
  }

  void changePage(int newPage) {
    if (newPage >= 1 && newPage <= _totalPages && newPage != _currentPage) {
      _currentPage = newPage;
      _updatePagination();
      onPageChanged?.call();
    }
  }

  void changeItemsPerPage(int newItemsPerPage) {
    _itemsPerPage = newItemsPerPage;
    _currentPage = 1; // Retour à la première page
    _updatePagination();
    onPageChanged?.call();
  }

  void goToFirstPage() {
    changePage(1);
  }

  void goToLastPage() {
    changePage(_totalPages);
  }

  void goToPreviousPage() {
    if (_currentPage > 1) {
      changePage(_currentPage - 1);
    }
  }

  void goToNextPage() {
    if (_currentPage < _totalPages) {
      changePage(_currentPage + 1);
    }
  }

  List<int> getVisiblePageNumbers({int maxVisiblePages = 3}) {
    int startPage = (_currentPage - 1).clamp(1, _totalPages);
    int endPage = (_currentPage + 1).clamp(1, _totalPages);

    if (endPage - startPage < maxVisiblePages - 1) {
      if (startPage == 1) {
        endPage = (startPage + maxVisiblePages - 1).clamp(1, _totalPages);
      } else {
        startPage = (endPage - maxVisiblePages + 1).clamp(1, _totalPages);
      }
    }

    List<int> pages = [];
    for (int i = startPage; i <= endPage; i++) {
      pages.add(i);
    }
    return pages;
  }

  bool canGoToPreviousPage() {
    return _currentPage > 1;
  }

  bool canGoToNextPage() {
    return _currentPage < _totalPages;
  }

  String getPaginationInfo() {
    return 'Page $_currentPage sur $_totalPages (${_items.length} résultats)';
  }

  void _updatePagination() {
    _totalPages = (_items.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    if (_currentPage > _totalPages) _currentPage = _totalPages;
    if (_currentPage < 1) _currentPage = 1;

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;

    _displayedItems = _items.sublist(
      startIndex,
      endIndex > _items.length ? _items.length : endIndex,
    );
  }

  void resetToFirstPage() {
    _currentPage = 1;
    _updatePagination();
    onPageChanged?.call();
  }

  void dispose() {
    onPageChanged = null;
  }
}