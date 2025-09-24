import 'package:flutter/material.dart';

class WebActiveFilterBar extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const WebActiveFilterBar({
    super.key,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withOpacity(0.08),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.blue[800], fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(onTap: onClear, child: const Icon(Icons.close, color: Colors.blue, size: 16)),
        ],
      ),
    );
  }
}
