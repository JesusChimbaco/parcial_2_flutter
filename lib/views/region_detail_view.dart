import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/region.dart';
import '../services/region_service.dart';
import '../enums/loading_state.dart';

class RegionDetailView extends StatefulWidget {
  final String regionId;

  const RegionDetailView({
    Key? key,
    required this.regionId,
  }) : super(key: key);

  @override
  State<RegionDetailView> createState() => _RegionDetailViewState();
}

class _RegionDetailViewState extends State<RegionDetailView> {
  final RegionService _regionService = RegionService();
  LoadingState _loadingState = LoadingState.initial;
  Region? _region;
  String? _errorMessage;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadRegionDetail();
  }

  Future<void> _loadRegionDetail() async {
    if (_loadingState != LoadingState.loading) {
      setState(() {
        _loadingState = LoadingState.loading;
        _errorMessage = null;
      });

      try {
        final response = await _regionService.getRegionById(int.parse(widget.regionId));
        
        if (mounted) {
          if (response.success && response.data != null) {
            setState(() {
              _region = response.data!;
              _loadingState = LoadingState.loaded;
            });
          } else {
            setState(() {
              _loadingState = LoadingState.error;
              _errorMessage = response.error ?? 'Región no encontrada';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loadingState = LoadingState.error;
            _errorMessage = 'Error al cargar los datos de la región: $e';
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
      final response = await _regionService.getRegionById(int.parse(widget.regionId));
      
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _region = response.data!;
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
          _region?.name ?? 'Detalles de la Región',
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
            onPressed: () => context.go('/regions'),
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
              onPressed: _loadRegionDetail,
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
    if (_region == null) {
      return _buildNotFoundState();
    }

    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildInfoCard(),
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
              Icons.location_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Región no encontrada',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La región solicitada no existe o no está disponible',
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
                  Icons.location_on,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _region?.name ?? 'Sin nombre',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Región #${_region?.id}',
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

  Widget _buildInfoCard() {
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
              'ID',
              _region?.id.toString() ?? 'N/A',
              Icons.tag,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Nombre',
              _region?.name ?? 'Sin nombre',
              Icons.location_city,
            ),
            if (_region?.description != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                'Descripción',
                _region!.description!,
                Icons.description,
                isMultiline: true,
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
                    'ID de la Región',
                    _region?.id.toString() ?? '0',
                    Icons.numbers,
                    theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Caracteres en Nombre',
                    (_region?.name.length ?? 0).toString(),
                    Icons.text_fields,
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            if (_region?.description != null) ...[
              const SizedBox(height: 16),
              _buildStatItem(
                'Caracteres en Descripción',
                _region!.description!.length.toString(),
                Icons.description,
                theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
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
}