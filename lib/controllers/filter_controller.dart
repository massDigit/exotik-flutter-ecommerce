
class FilterController {
  String? _searchQuery;
  String? _selectedCategory;
  String _selectedSearchDisplay = '';

  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String get selectedSearchDisplay => _selectedSearchDisplay;
  bool get hasActiveFilters => _searchQuery != null || _selectedCategory != null;

  void Function()? onFiltersChanged;

  void applySearch(String searchTerm) {
    _searchQuery = searchTerm.isEmpty ? null : searchTerm;
    _selectedSearchDisplay = searchTerm;
    _selectedCategory = null;
    onFiltersChanged?.call();
  }

  void applyCategory(String category) {
    _selectedCategory = category;
    _selectedSearchDisplay = 'Catégorie: $category';
    _searchQuery = null;
    onFiltersChanged?.call();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedSearchDisplay = '';
    onFiltersChanged?.call();
  }


  String getActiveFilterDisplay(int resultCount) {
    if (hasActiveFilters) {
      return 'Recherche active: $_selectedSearchDisplay ($resultCount résultats)';
    }
    return '';
  }


  bool hasSearchQuery() {
    return _searchQuery != null && _searchQuery!.isNotEmpty;
  }


  bool hasCategoryFilter() {
    return _selectedCategory != null && _selectedCategory!.isNotEmpty;
  }

  void dispose() {
    onFiltersChanged = null;
  }
}