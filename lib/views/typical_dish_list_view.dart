import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/services.dart';

class TypicalDishListView extends StatefulWidget {
  const TypicalDishListView({super.key});

  @override
  State<TypicalDishListView> createState() => _TypicalDishListViewState();
}

class _TypicalDishListViewState extends State<TypicalDishListView> {
  final TypicalDishService _service = TypicalDishService();
  final TextEditingController _searchController = TextEditingController();
  
  LoadingState _loadingState = LoadingState.loading;
  List<TypicalDish> _dishes = [];
  List<TypicalDish> _filteredDishes = [];
  String _selectedRegion = 'Todas';
  String _errorMessage = '';
  
  final List<String> _regions = [
    'Todas',
    'Región Andina',
    'Región Caribe',
    'Región Pacífica',
    'Región Orinoquía',
    'Región Amazonía'
  ];

  @override
  void initState() {
    super.initState();
    _loadDishes();
    _searchController.addListener(_filterDishes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      final response = await _service.getAllTypicalDishes();
      if (response.success && response.data != null) {
        setState(() {
          _dishes = response.data!;
          _filteredDishes = response.data!;
          _loadingState = LoadingState.loaded;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Error desconocido';
          _loadingState = LoadingState.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los platos típicos: $e';
        _loadingState = LoadingState.error;
      });
    }
  }

  void _filterDishes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDishes = _dishes.where((dish) {
        final matchesSearch = dish.name.toLowerCase().contains(query);
        final matchesRegion = _selectedRegion == 'Todas' || 
                             (dish.departmentName?.toLowerCase().contains(_selectedRegion.toLowerCase()) ?? false);
        return matchesSearch && matchesRegion;
      }).toList();
    });
  }

  void _onRegionChanged(String? newRegion) {
    if (newRegion != null) {
      setState(() {
        _selectedRegion = newRegion;
      });
      _filterDishes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos Típicos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDishes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros y búsqueda
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar platos típicos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Filtro por región
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Región: '),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedRegion,
                        onChanged: _onRegionChanged,
                        items: _regions.map((region) {
                          return DropdownMenuItem<String>(
                            value: region,
                            child: Text(region),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de platos
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando platos típicos...'),
            ],
          ),
        );
        
      case LoadingState.error:
        return Center(
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
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDishes,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
        
      case LoadingState.loaded:
        if (_filteredDishes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No se encontraron platos típicos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _filteredDishes.length,
          itemBuilder: (context, index) {
            final dish = _filteredDishes[index];
            return _buildDishCard(dish);
          },
        );
        
      case LoadingState.empty:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No hay platos típicos disponibles',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildDishCard(TypicalDish dish) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            dish.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          dish.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dish.departmentName ?? 'Región no especificada',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${dish.ingredients.length} ingredientes',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go('/typical-dishes/${dish.id}');
        },
      ),
    );
  }
}