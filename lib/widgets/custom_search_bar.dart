import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final List<String> suggestions;
  final Function(String)? onSearchSelected;
  final VoidCallback? onFilterPressed;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Rechercher...',
    this.suggestions = const [],
    this.onSearchSelected,
    this.onFilterPressed,
  });


  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            hintText: widget.hintText,
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
            trailing: <Widget>[
              // Bouton de filtres
              Tooltip(
                message: 'Filtres',
                child: IconButton(
                  onPressed: widget.onFilterPressed ?? () {
                    debugPrint('Ouvrir les filtres');
                  },
                  icon: const Icon(Icons.tune),
                ),
              ),
            ],
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          // Utiliser les suggestions passées en paramètre
          final List<String> searchSuggestions = widget.suggestions.isNotEmpty
              ? widget.suggestions
              : _getDefaultSuggestions();

          // Filtrer selon le texte tapé
          final String query = controller.text.toLowerCase();
          final filteredSuggestions = query.isEmpty
              ? searchSuggestions
              : searchSuggestions.where((item) =>
              item.toLowerCase().contains(query)
          ).toList();

          return filteredSuggestions.map<ListTile>((String item) {
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(item),
              onTap: () {
                controller.closeView(item);
                // Appeler la fonction callback
                if (widget.onSearchSelected != null) {
                  widget.onSearchSelected!(item);
                }
              },
            );
          }).toList();
        },
      ),
    );
  }

  // Suggestions par défaut si aucune n'est fournie
  List<String> _getDefaultSuggestions() {
    return [
      'iPhone 15 Pro',
      'MacBook Air',
      'AirPods Pro',
      'Apple Watch',
      'Samsung Galaxy',
      'iPad Air',
      'Casque Bluetooth',
      'Chargeur sans fil',
    ];
  }
}