import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/controllers/pagination_controller.dart';

class WebPaginationToolbar extends StatelessWidget {
  final PaginationController controller;

  const WebPaginationToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Liste standard Web + inclusion de la value courante si besoin
    final base = <int>[12, 24, 48, 96];
    final itemsList = base.contains(controller.itemsPerPage)
        ? base
        : ([controller.itemsPerPage, ...base]..sort());

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                controller.getPaginationInfo(),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: controller.itemsPerPage,
              items: itemsList
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v par page')))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.changeItemsPerPage(v);
              },
              underline: const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: controller.canGoToPreviousPage() ? controller.goToFirstPage : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'Première page',
              ),
              IconButton(
                onPressed: controller.canGoToPreviousPage() ? controller.goToPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Page précédente',
              ),
              ...controller.getVisiblePageNumbers().map((n) {
                final isCurrent = n == controller.currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: isCurrent ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => controller.changePage(n),
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey[800],
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                onPressed: controller.canGoToNextPage() ? controller.goToNextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Page suivante',
              ),
              IconButton(
                onPressed: controller.canGoToNextPage() ? controller.goToLastPage : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Dernière page',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
