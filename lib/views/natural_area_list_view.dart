import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/services.dart';

class NaturalAreaListView extends StatefulWidget {
  const NaturalAreaListView({super.key});

  @override
  State<NaturalAreaListView> createState() => _NaturalAreaListViewState();
}

class _NaturalAreaListViewState extends State<NaturalAreaListView> {
  final NaturalAreaService _service = NaturalAreaService();
  final TextEditingController _searchController = TextEditingController();
  
  LoadingState _loadingState = LoadingState.loading;
  List<NaturalArea> _areas = [];
  List<NaturalArea> _filteredAreas = [];
  String _selectedDepartment = 'Todos';
  String _errorMessage = '';
  
  final List<String> _departments = [
    'Todos',
    'Amazonas',
    'Antioquia',
    'Arauca',
    'Atlántico',
    'Bolívar',
    'Boyacá',
    'Caldas',
    'Caquetá',
    'Casanare',
    'Cauca',
    'Cesar',
    'Chocó',
    'Córdoba',
    'Cundinamarca',
    'Guainía',
    'Guaviare',
    'Huila',
    'La Guajira',
    'Magdalena',
    'Meta',
    'Nariño',
    'Norte de Santander',
    'Putumayo',
    'Quindío',
    'Risaralda',
    'San Andrés y Providencia',
    'Santander',
    'Sucre',
    'Tolima',
    'Valle del Cauca',
    'Vaupés',
    'Vichada'
  ];

  @override
  void initState() {
    super.initState();
    _loadAreas();
    _searchController.addListener(_filterAreas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      final response = await _service.getAllNaturalAreas();
      if (response.success && response.data != null) {
        setState(() {
          _areas = response.data!;
          _filteredAreas = response.data!;
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
        _errorMessage = 'Error al cargar las áreas naturales: $e';
        _loadingState = LoadingState.error;
      });
    }
  }

  void _filterAreas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAreas = _areas.where((area) {
        final matchesSearch = area.name.toLowerCase().contains(query);
        final matchesDepartment = _selectedDepartment == 'Todos' || 
                                 (area.departmentName?.toLowerCase().contains(_selectedDepartment.toLowerCase()) ?? false);
        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  void _onDepartmentChanged(String? newDepartment) {
    if (newDepartment != null) {
      setState(() {
        _selectedDepartment = newDepartment;
      });
      _filterAreas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Áreas Naturales'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAreas,
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
                    hintText: 'Buscar áreas naturales...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Filtro por departamento
                Row(
                  children: [
                    const Icon(Icons.location_city, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Departamento: '),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedDepartment,
                        onChanged: _onDepartmentChanged,
                        items: _departments.map((department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de áreas
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
              Text('Cargando áreas naturales...'),
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
                onPressed: _loadAreas,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
        
      case LoadingState.loaded:
        if (_filteredAreas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.nature,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No se encontraron áreas naturales',
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
          itemCount: _filteredAreas.length,
          itemBuilder: (context, index) {
            final area = _filteredAreas[index];
            return _buildAreaCard(area);
          },
        );
        
      case LoadingState.empty:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nature,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No hay áreas naturales disponibles',
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

  Widget _buildAreaCard(NaturalArea area) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.nature,
            color: Colors.white,
          ),
        ),
        title: Text(
          area.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (area.departmentName != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_city, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      area.departmentName!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            if (area.departmentId != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Departamento ID: ${area.departmentId}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (area.landArea != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.crop_free, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${area.landArea} ha',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go('/natural-areas/${area.id}');
        },
      ),
    );
  }
}