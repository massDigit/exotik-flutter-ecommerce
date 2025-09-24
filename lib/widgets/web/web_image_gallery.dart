import 'package:flutter/material.dart';

class WebImageGallery extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double height;

  const WebImageGallery({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onSelect,
    this.height = 520,
  });

  @override
  Widget build(BuildContext context) {
    final safeImages = images.isEmpty ? <String>[] : images;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image principale
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey[100],
              child: safeImages.isEmpty
                  ? _fallback()
                  : Image.network(
                safeImages[selectedIndex.clamp(0, safeImages.length - 1)],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, prog) => prog == null
                    ? child
                    : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                errorBuilder: (_, __, ___) => _fallback(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Miniatures
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: safeImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final selected = i == selectedIndex;
              return InkWell(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300, width: selected ? 2 : 1),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    safeImages[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _fallback() => Container(
    color: Colors.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported, color: Colors.grey[600]),
        const SizedBox(height: 6),
        Text('Image indisponible', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    ),
  );
}
