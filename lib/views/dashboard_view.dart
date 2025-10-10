import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Abiertos de Colombia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Grid de servicios principales
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
            _buildDashboardCard(
              context,
              title: 'Platos Típicos',
              subtitle: 'Descubre la gastronomía colombiana',
              icon: Icons.restaurant,
              color: Colors.orange,
              onTap: () => context.go('/typical-dishes'),
            ),
            _buildDashboardCard(
              context,
              title: 'Áreas Naturales',
              subtitle: 'Explora la biodiversidad',
              icon: Icons.nature,
              color: Colors.green,
              onTap: () => context.go('/natural-areas'),
            ),
            _buildDashboardCard(
              context,
              title: 'Regiones',
              subtitle: 'Divisiones territoriales',
              icon: Icons.location_on,
              color: Colors.blue,
              onTap: () => context.go('/regions'),
            ),
            _buildDashboardCard(
              context,
              title: 'Especies Invasivas',
              subtitle: 'Biodiversidad amenazante',
              icon: Icons.pets,
              color: Colors.red,
              onTap: () => context.go('/invasive-species'),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}