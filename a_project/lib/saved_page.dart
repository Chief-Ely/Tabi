// saved_page.dart
import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Translations'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(6, (index) {
          return Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark, size: 40),
                  SizedBox(height: 8),
                  Text('Saved #${index + 1}'),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}