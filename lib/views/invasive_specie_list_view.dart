import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/invasive_specie.dart';
import '../services/invasive_specie_service.dart';
import '../enums/loading_state.dart';

class InvasiveSpecieListView extends StatefulWidget {
  const InvasiveSpecieListView({Key? key}) : super(key: key);

  @override
  State<InvasiveSpecieListView> createState() => _InvasiveSpecieListViewState();
}

class _InvasiveSpecieListViewState extends State<InvasiveSpecieListView> {
  final InvasiveSpecieService _invasiveSpecieService = InvasiveSpecieService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  LoadingState _loadingState = LoadingState.initial;
  List<InvasiveSpecie> _allSpecies = [];
  List<InvasiveSpecie> _filteredSpecies = [];
  String? _errorMessage;
  bool _isRefreshing = false;
  String? _selectedRiskLevel;
  List<String> _availableRiskLevels = [];

  @override
  void initState() {
    super.initState();
    _loadSpecies();
    _searchController.addListener(_filterSpecies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    if (_loadingState != LoadingState.loading) {
      setState(() {
        _loadingState = LoadingState.loading;
        _errorMessage = null;
      });

      try {
        final response = await _invasiveSpecieService.getAllInvasiveSpecies();
        
        if (mounted) {
          if (response.success && response.data != null && response.data!.isNotEmpty) {
            final riskLevels = await _invasiveSpecieService.getUniqueRiskLevels();
            
            setState(() {
              _allSpecies = response.data!;
              _filteredSpecies = _allSpecies;
              _availableRiskLevels = riskLevels;
              _loadingState = LoadingState.loaded;
            });
          } else {
            setState(() {
              _loadingState = LoadingState.empty;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loadingState = LoadingState.error;
            _errorMessage = 'Error al cargar las especies invasivas: $e';
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
      final response = await _invasiveSpecieService.getAllInvasiveSpecies();
      
      if (mounted) {
        if (response.success && response.data != null) {
          final riskLevels = await _invasiveSpecieService.getUniqueRiskLevels();
          
          setState(() {
            _allSpecies = response.data!;
            _availableRiskLevels = riskLevels;
            _errorMessage = null;
            _loadingState = _allSpecies.isEmpty ? LoadingState.empty : LoadingState.loaded;
          });
          
          _filterSpecies();
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

  void _filterSpecies() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _filteredSpecies = _allSpecies.where((specie) {
        final matchesSearch = query.isEmpty ||
            specie.name.toLowerCase().contains(query) ||
            (specie.scientificName?.toLowerCase().contains(query) ?? false);
            
        final matchesRiskLevel = _selectedRiskLevel == null ||
            specie.riskLevel == _selectedRiskLevel;
            
        return matchesSearch && matchesRiskLevel;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRiskLevel = null;
      _filteredSpecies = _allSpecies;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Especies Invasivas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceContainer,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al Dashboard',
        ),
        actions: [
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
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final theme = Theme.of(context);
    final hasFilters = _searchController.text.isNotEmpty || _selectedRiskLevel != null;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.outline.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o nombre científico...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filtros
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRiskLevel,
                  decoration: InputDecoration(
                    labelText: 'Nivel de Riesgo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, 
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los niveles'),
                    ),
                    ..._availableRiskLevels.map((level) => DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRiskLevel = value;
                    });
                    _filterSpecies();
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              if (hasFilters)
                IconButton(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_list_off),
                  tooltip: 'Limpiar filtros',
                ),
            ],
          ),
          
          // Contador de resultados
          if (_loadingState == LoadingState.loaded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_filteredSpecies.length} de ${_allSpecies.length} especies',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
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

      case LoadingState.empty:
        return _buildEmptyState();

      case LoadingState.loaded:
        return _buildSpeciesList();
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
              onPressed: _loadSpecies,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'No se encontraron especies',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay especies invasivas disponibles en este momento',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadSpecies,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesList() {
    if (_filteredSpecies.isEmpty) {
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
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Sin resultados',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No se encontraron especies con los filtros actuales',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredSpecies.length,
      itemBuilder: (context, index) {
        final specie = _filteredSpecies[index];
        return _buildSpecieCard(specie);
      },
    );
  }

  Widget _buildSpecieCard(InvasiveSpecie specie) {
    final theme = Theme.of(context);
    final riskColor = _getRiskLevelColor(specie.riskLevel);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/invasive-species/${specie.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nivel de riesgo
              Row(
                children: [
                  Expanded(
                    child: Text(
                      specie.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (specie.riskLevel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: riskColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        specie.riskLevel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Nombre científico
              if (specie.scientificName != null) ...[
                const SizedBox(height: 4),
                Text(
                  specie.scientificName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'ID: ${specie.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
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
}