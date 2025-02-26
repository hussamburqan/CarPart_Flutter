import 'package:flutter/material.dart';

import '../../Services/localizations.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function() onNext;
  final Function() onPrevious;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onPrevious,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: currentPage > 1 ? onPrevious : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentPage > 1 ? Colors.blue : Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.translate('previous')!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${AppLocalizations.of(context)!.translate('page')!} $currentPage ${AppLocalizations.of(context)!.translate('of')!} $totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: currentPage < totalPages ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentPage < totalPages ? Colors.blue : Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('next')!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}