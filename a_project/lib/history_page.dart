import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sample history data
    final List<Map<String, String>> historyItems = [
      {
        'from': 'Bisaya',
        'to': 'Tagalog',
        'text': 'Kumusta ka?',
        'translation': 'Kamusta ka?'
      },
      {
        'from': 'Tagalog',
        'to': 'Bisaya',
        'text': 'Salamat',
        'translation': 'Salamat'
      },
      {
        'from': 'Bisaya',
        'to': 'Tagalog',
        'text': 'Gutom na ko',
        'translation': 'Gutom na ako'
      },
      // Add more items as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: historyItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.iconTheme.color?.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No translation history yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: theme.cardColor,
                  child: ListTile(
                    leading: Icon(Icons.history, color: theme.iconTheme.color),
                    title: Text(
                      item['text']!,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${item['from']} → ${item['to']}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: theme.iconTheme.color,
                    ),
                    onTap: () {
                      // Show translation details
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: theme.dialogBackgroundColor,
                          title: Text(
                            'Translation Details',
                            style: theme.textTheme.titleLarge,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original (${item['from']}):',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(item['text']!),
                              const SizedBox(height: 16),
                              Text(
                                'Translation (${item['to']}):',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(item['translation']!),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
