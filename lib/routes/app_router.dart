import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/dashboard_view.dart';
import '../views/typical_dish_list_view.dart';
import '../views/typical_dish_detail_view.dart';
import '../views/natural_area_list_view.dart';
import '../views/natural_area_detail_view.dart';
import '../views/region_list_view.dart';
import '../views/region_detail_view.dart';
import '../views/invasive_specie_list_view.dart';
import '../views/invasive_specie_detail_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Dashboard Route
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardView(),
      ),
      
      // Typical Dish Routes
      GoRoute(
        path: '/typical-dishes',
        name: 'typical-dishes',
        builder: (context, state) => const TypicalDishListView(),
      ),
      GoRoute(
        path: '/typical-dishes/:id',
        name: 'typical-dish-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TypicalDishDetailView(dishId: int.parse(id));
        },
      ),
      
      // Natural Area Routes
      GoRoute(
        path: '/natural-areas',
        name: 'natural-areas',
        builder: (context, state) => const NaturalAreaListView(),
      ),
      GoRoute(
        path: '/natural-areas/:id',
        name: 'natural-area-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NaturalAreaDetailView(areaId: int.parse(id));
        },
      ),
      
      // Region Routes
      GoRoute(
        path: '/regions',
        name: 'regions',
        builder: (context, state) => const RegionListView(),
      ),
      GoRoute(
        path: '/regions/:id',
        name: 'region-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RegionDetailView(regionId: id);
        },
      ),
      
      // Invasive Species Routes
      GoRoute(
        path: '/invasive-species',
        name: 'invasive-species',
        builder: (context, state) => const InvasiveSpecieListView(),
      ),
      GoRoute(
        path: '/invasive-species/:id',
        name: 'invasive-specie-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return InvasiveSpecieDetailView(specieId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ir al Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}