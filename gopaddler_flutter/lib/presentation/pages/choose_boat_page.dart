import 'package:flutter/material.dart';

class ChooseBoatPage extends StatelessWidget {
  final Function(String) onBoatSelected;

  const ChooseBoatPage({
    Key? key,
    required this.onBoatSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const boats = [
      ('kayak_single', 'Single Kayak', Icons.water),
      ('kayak_double', 'Double Kayak', Icons.groups),
      ('canoe', 'Canoe', Icons.directions_boat),
      ('dragon_boat', 'Dragon Boat', Icons.auto_awesome),
      ('sup', 'SUP', Icons.surfing),
      ('outrigger', 'Outrigger', Icons.waves),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Boat Type'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: boats.length,
          itemBuilder: (context, index) {
            final (id, name, icon) = boats[index];
            return _BoatCard(
              id: id,
              name: name,
              icon: icon,
              onTap: () {
                onBoatSelected(id);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BoatCard extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _BoatCard({
    required this.id,
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
