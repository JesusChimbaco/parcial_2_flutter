import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/invasive_specie.dart';
import '../services/invasive_specie_service.dart';
import '../enums/loading_state.dart';

class InvasiveSpecieDetailView extends StatefulWidget {
  final String specieId;

  const InvasiveSpecieDetailView({
    Key? key,
    required this.specieId,
  }) : super(key: key);

  @override
  State<InvasiveSpecieDetailView> createState() => _InvasiveSpecieDetailViewState();
}

class _InvasiveSpecieDetailViewState extends State<InvasiveSpecieDetailView> {
  final InvasiveSpecieService _invasiveSpecieService = InvasiveSpecieService();
  LoadingState _loadingState = LoadingState.initial;
  InvasiveSpecie? _specie;
  String? _errorMessage;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadSpecieDetail();
  }

  Future<void> _loadSpecieDetail() async {
    if (_loadingState != LoadingState.loading) {
      setState(() {
        _loadingState = LoadingState.loading;
        _errorMessage = null;
      });

      try {
        final response = await _invasiveSpecieService.getInvasiveSpecieById(int.parse(widget.specieId));
        
        if (mounted) {
          if (response.success && response.data != null) {
            setState(() {
              _specie = response.data!;
              _loadingState = LoadingState.loaded;
            });
          } else {
            setState(() {
              _loadingState = LoadingState.error;
              _errorMessage = response.error ?? 'Especie no encontrada';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loadingState = LoadingState.error;
            _errorMessage = 'Error al cargar los datos de la especie: $e';
          });
        }
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final response = await _invasiveSpecieService.getInvasiveSpecieById(int.parse(widget.specieId));
      
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _specie = response.data!;
            _loadingState = LoadingState.loaded;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Error al actualizar';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al actualizar: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _specie?.name ?? 'Detalles de Especie Invasiva',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceContainer,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/invasive-species'),
            tooltip: 'Volver a la lista',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
            tooltip: 'Ir al Dashboard',
          ),
          IconButton(
            icon: _isRefreshing 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onSurface,
                    ),
                  ),
                )
              : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Actualizar información',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildContent(),
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
        return _buildDetailContent();
    }
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 64),
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los datos',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadSpecieDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver atrás'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent() {
    if (_specie == null) {
      return _buildNotFoundState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          _buildRiskInfoCard(),
          if (_specie!.hasImage) ...[
            const SizedBox(height: 16),
            _buildImageCard(),
          ],
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 64),
            Icon(
              Icons.pets_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Especie no encontrada',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La especie solicitada no existe o no está disponible',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver atrás'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final theme = Theme.of(context);
    final riskColor = _getRiskLevelColor(_specie!.riskLevel);
    
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _specie!.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_specie!.scientificName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _specie!.scientificName!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_specie!.riskLevel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _specie!.riskLevel!.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${_specie!.id}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información General',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Nombre',
              _specie!.name,
              Icons.label,
            ),
            if (_specie!.scientificName != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                'Nombre Científico',
                _specie!.scientificName!,
                Icons.science,
              ),
            ],
            if (_specie!.commonNames != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                'Nombres Comunes',
                _specie!.commonNames!,
                Icons.pets,
              ),
            ],
            if (_specie!.impact != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                'Impacto',
                _specie!.impact!,
                Icons.warning_amber,
                isMultiline: true,
              ),
            ],
            if (_specie!.manage != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                'Manejo y Control',
                _specie!.manage!,
                Icons.settings,
                isMultiline: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskInfoCard() {
    final theme = Theme.of(context);
    final riskColor = _getRiskLevelColor(_specie!.riskLevel);
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Evaluación de Riesgo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_specie!.riskLevel != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: riskColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getRiskIcon(_specie!.riskLevel!),
                      color: riskColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nivel de Riesgo: ${_specie!.riskLevel!.toUpperCase()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRiskDescription(_specie!.riskLevel!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.outline,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nivel de Riesgo No Especificado',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: theme.colorScheme.tertiary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Imagen',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagen disponible',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'La especie tiene una imagen asociada',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estadísticas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'ID de la Especie',
                    _specie!.id.toString(),
                    Icons.numbers,
                    theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Caracteres en Nombre',
                    _specie!.name.length.toString(),
                    Icons.text_fields,
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            if (_specie!.scientificName != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Nombre Científico',
                      _specie!.scientificName!.length.toString(),
                      Icons.science,
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Tiene Imagen',
                      _specie!.hasImage ? 'Sí' : 'No',
                      Icons.image,
                      _specie!.hasImage ? Colors.green : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: isMultiline ? null : 1,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(String? riskLevel) {
    final theme = Theme.of(context);
    
    switch (riskLevel?.toLowerCase()) {
      case 'alto':
      case 'high':
        return theme.colorScheme.error;
      case 'medio':
      case 'medium':
        return Colors.orange;
      case 'bajo':
      case 'low':
        return Colors.green;
      default:
        return theme.colorScheme.outline;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'alto':
      case 'high':
        return Icons.dangerous;
      case 'medio':
      case 'medium':
        return Icons.warning;
      case 'bajo':
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getRiskDescription(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'alto':
      case 'high':
        return 'Esta especie representa un alto riesgo para el ecosistema';
      case 'medio':
      case 'medium':
        return 'Esta especie representa un riesgo moderado';
      case 'bajo':
      case 'low':
        return 'Esta especie representa un riesgo bajo';
      default:
        return 'Nivel de riesgo no especificado';
    }
  }
}