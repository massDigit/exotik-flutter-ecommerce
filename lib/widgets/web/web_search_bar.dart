import 'package:flutter/material.dart';

class WebSearchBar extends StatefulWidget {
  final String hintText;
  final List<String> suggestions;
  final ValueChanged<String> onSearchSelected;
  final VoidCallback? onFilterPressed;
  final double height;

  const WebSearchBar({
    super.key,
    required this.hintText,
    required this.suggestions,
    required this.onSearchSelected,
    this.onFilterPressed,
    this.height = 44,
  });

  @override
  State<WebSearchBar> createState() => _WebSearchBarState();
}

class _WebSearchBarState extends State<WebSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  final _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  List<String> _filtered = const [];
  int _highlightIndex = -1;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
    _controller.addListener(_handleTextChanged);
    _recomputeFiltered();
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_handleFocus);
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focusNode.hasFocus) {
      _ensureOverlay();
    } else {
      // Laisse le temps à un tap sur une suggestion de passer
      Future.delayed(const Duration(milliseconds: 100), _removeOverlay);
    }
  }

  void _handleTextChanged() {
    _recomputeFiltered();
    _rebuildOverlay();
  }

  void _recomputeFiltered() {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = widget.suggestions.take(8).toList();
    } else {
      _filtered = widget.suggestions
          .where((s) => s.toLowerCase().contains(q))
          .take(8)
          .toList();
    }
    setState(() {});
  }

  void _ensureOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _rebuildOverlay();
    }
  }

  void _rebuildOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _highlightIndex = -1;
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        // Mesure la largeur du champ pour caler l’overlay
        final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        final width = box?.size.width ?? 320;

        return Positioned.fill(
          child: IgnorePointer(
            ignoring: !_focusNode.hasFocus,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(onTap: _removeOverlay),
                ),
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, widget.height + 6),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: SizedBox(
                        width: width,
                        child: _filtered.isEmpty
                            ? const SizedBox.shrink()
                            : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
                          itemBuilder: (context, index) {
                            final s = _filtered[index];
                            final highlighted = index == _highlightIndex;
                            return MouseRegion(
                              onEnter: (_) => setState(() => _highlightIndex = index),
                              child: InkWell(
                                onTap: () => _selectSuggestion(s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  color: highlighted ? Colors.blue.withOpacity(0.06) : null,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, size: 18, color: Colors.black54),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          s,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectSuggestion(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: value.length));
    widget.onSearchSelected(value);
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.onSearchSelected(value);
    }
    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        key: _fieldKey,
        height: h,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onSubmitted: (_) => _submit(),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),

            prefixIcon: const Icon(Icons.search, size: 20),
            prefixIconConstraints: BoxConstraints(
              minWidth: h,
              minHeight: h,
            ),

            suffixIcon: widget.onFilterPressed == null
                ? null
                : IconButton(
              onPressed: widget.onFilterPressed,
              icon: const Icon(Icons.tune, size: 20),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: h,
                minHeight: h,
              ),
              tooltip: 'Filtrer',
            ),
          ),
        ),
      ),
    );
  }
}
