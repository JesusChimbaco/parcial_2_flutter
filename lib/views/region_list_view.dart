import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/region.dart';
import '../services/region_service.dart';
import '../enums/loading_state.dart';

class RegionListView extends StatefulWidget {
  const RegionListView({super.key});

  @override
  State<RegionListView> createState() => _RegionListViewState();
}

class _RegionListViewState extends State<RegionListView> {
  final RegionService _service = RegionService();
  final TextEditingController _searchController = TextEditingController();
  
  LoadingState _loadingState = LoadingState.loading;
  List<Region> _regions = [];
  List<Region> _filteredRegions = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      final response = await _service.getAllRegions();
      if (response.success && response.data != null) {
        setState(() {
          _regions = response.data!;
          _filteredRegions = _regions;
          _loadingState = LoadingState.loaded;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'No se pudieron cargar las regiones';
          _loadingState = LoadingState.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
        _loadingState = LoadingState.error;
      });
    }
  }

  void _filterRegions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRegions = _regions;
      } else {
        _filteredRegions = _regions
            .where((region) =>
                region.name.toLowerCase().contains(query.toLowerCase()) ||
                (region.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regiones de Colombia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegions,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar regiones...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterRegions('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterRegions,
            ),
          ),

          // Contenido principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case LoadingState.error:
        return _buildErrorState();

      case LoadingState.loaded:
      case LoadingState.empty:
        return _buildLoadedState();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar regiones',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRegions,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState() {
    if (_filteredRegions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No hay regiones disponibles'
                  : 'No se encontraron regiones',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegions,
      child: Column(
        children: [
          // Información de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredRegions.length} regiones encontradas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Lista de regiones
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredRegions.length,
              itemBuilder: (context, index) {
                final region = _filteredRegions[index];
                return _buildRegionCard(region);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard(Region region) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/regions/${region.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con nombre
              Row(
                children: [
                  Icon(
                    Icons.place,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      region.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              if (region.description != null && region.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  region.description!.length > 120
                      ? '${region.description!.substring(0, 120)}...'
                      : region.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Información adicional
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: ${region.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}