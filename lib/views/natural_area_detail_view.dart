import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/services.dart';

class NaturalAreaDetailView extends StatefulWidget {
  final int areaId;

  const NaturalAreaDetailView({
    super.key,
    required this.areaId,
  });

  @override
  State<NaturalAreaDetailView> createState() => _NaturalAreaDetailViewState();
}

class _NaturalAreaDetailViewState extends State<NaturalAreaDetailView> {
  final NaturalAreaService _service = NaturalAreaService();
  
  LoadingState _loadingState = LoadingState.loading;
  NaturalArea? _area;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadArea();
  }

  Future<void> _loadArea() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      final response = await _service.getNaturalAreaById(widget.areaId);
      if (response.success && response.data != null) {
        setState(() {
          _area = response.data;
          _loadingState = LoadingState.loaded;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'No se encontró el área natural';
          _loadingState = LoadingState.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el área natural: $e';
        _loadingState = LoadingState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_area?.name ?? 'Área Natural'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/natural-areas'),
            tooltip: 'Volver a la lista',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
            tooltip: 'Ir al Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArea,
          ),
        ],
      ),
      body: _buildBody(),
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
              Text('Cargando detalles del área natural...'),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadArea,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
        
      case LoadingState.loaded:
        if (_area == null) {
          return const Center(
            child: Text('No se encontró información del área natural'),
          );
        }
        return _buildAreaDetails();
        
      case LoadingState.empty:
        return const Center(
          child: Text('No hay información disponible'),
        );
    }
  }

  Widget _buildAreaDetails() {
    final area = _area!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del área
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.nature,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              area.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (area.departmentName != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.location_city, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      area.departmentName!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Información básica
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.tag,
                        label: 'ID: ${area.id}',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      if (area.landArea != null)
                        _buildInfoChip(
                          icon: Icons.crop_free,
                          label: '${area.landArea} ha',
                          color: Colors.green,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Descripción (si existe)
          if (area.description.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      area.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Ubicación geográfica
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Ubicación Geográfica',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (area.departmentName != null) ...[
                    _buildDetailRow(
                      icon: Icons.location_city,
                      label: 'Departamento',
                      value: area.departmentName!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (area.areaGroupId != null) ...[
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Grupo de Área ID',
                      value: area.areaGroupId.toString(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (area.departmentId != null) ...[
                    _buildDetailRow(
                      icon: Icons.numbers,
                      label: 'ID Departamento',
                      value: area.departmentId.toString(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (area.categoryNaturalAreaId != null) ...[
                    _buildDetailRow(
                      icon: Icons.numbers,
                      label: 'ID Categoría de Área Natural',
                      value: area.categoryNaturalAreaId.toString(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Información adicional del área
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Información del Área',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDetailRow(
                    icon: Icons.tag,
                    label: 'ID del área',
                    value: area.id.toString(),
                  ),
                  
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.nature_people,
                    label: 'Nombre completo',
                    value: area.name,
                  ),
                  
                  if (area.landArea != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.square_foot,
                      label: 'Área total',
                      value: '${area.landArea} hectáreas',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}