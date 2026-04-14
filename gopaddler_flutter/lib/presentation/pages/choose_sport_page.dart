import 'package:flutter/material.dart';

class ChooseSportPage extends StatelessWidget {
  final Function(String) onSportSelected;

  const ChooseSportPage({
    Key? key,
    required this.onSportSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const sports = [
      ('paddling', 'Paddling', Icons.water, 'Kayaking, Canoeing, SUP'),
      ('cycling', 'Cycling', Icons.two_wheeler, 'Road, Mountain, BMX'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Sport Type'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: sports.length,
          itemBuilder: (context, index) {
            final (id, name, icon, description) = sports[index];
            return _SportCard(
              id: id,
              name: name,
              icon: icon,
              description: description,
              onTap: () {
                onSportSelected(id);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _SportCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 52, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
