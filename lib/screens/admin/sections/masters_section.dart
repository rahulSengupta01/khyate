import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/admin/admin_theme.dart';
import '../../../widgets/admin/admin_section_card.dart';
import '../../../widgets/admin/admin_filter_bar.dart';
import '../../../widgets/admin/admin_simple_table.dart';
import '../../../widgets/admin/admin_modal_form.dart';
import '../../../widgets/admin/admin_empty_state.dart';
import '../../../widgets/searchable_dropdown.dart';
import '../../../services/master_data_service.dart';

class MastersSection extends StatefulWidget {
  const MastersSection({super.key});

  @override
  State<MastersSection> createState() => _MastersSectionState();
}

class _MastersSectionState extends State<MastersSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _masterDataService = MasterDataService();
  final _locationSearchController = TextEditingController();
  List<dynamic> _allLocations = [];
  List<dynamic> _locations = [];
  List<dynamic> _allCategories = [];
  List<dynamic> _categories = [];
  /// Resolve country/city IDs to names when API returns only IDs (not populated).
  final Map<String, String> _countryNameById = {};
  final Map<String, String> _cityNameById = {};
  bool _loadingLocations = false;
  bool _loadingCategories = false;
  String _categorySearch = '';
  int _locationPage = 1;
  int _categoryPage = 1;
  static const _limit = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLocations();
    _loadCategories();
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _applyLocationSearch() {
    final query = _locationSearchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _locations = List<dynamic>.from(_allLocations));
      return;
    }
    setState(() {
      _locations = _allLocations.where((raw) {
        if (raw is! Map) return false;
        final loc = raw as Map;
        final countryStr = _getLocationCountryDisplay(loc);
        final cityStr = _getLocationCityDisplay(loc);
        final landmark = (loc['landmark'] ?? loc['name'] ?? '').toString().toLowerCase();
        final streetName = (loc['streetName'] ?? loc['address'] ?? '').toString().toLowerCase();
        final coords = _formatLocationCoordinates(loc).toLowerCase();
        return countryStr.toLowerCase().contains(query) ||
            cityStr.toLowerCase().contains(query) ||
            landmark.contains(query) ||
            streetName.contains(query) ||
            coords.contains(query);
      }).toList();
    });
  }

  String _getLocationCountryDisplay(Map<dynamic, dynamic> loc) {
    final countryVal = loc['country'] ?? loc['countryId'];
    if (countryVal == null) return '';
    if (countryVal is Map) {
      final name = (countryVal['name'] ?? countryVal['country_name'] ?? countryVal['countryName'] ?? '').toString();
      if (name.isNotEmpty) return name;
      final id = (countryVal['_id'] ?? countryVal['id'])?.toString();
      if (id != null) return _countryNameById[id] ?? id;
      return '';
    }
    return _countryNameById[countryVal.toString()] ?? countryVal.toString();
  }

  String _getLocationCityDisplay(Map<dynamic, dynamic> loc) {
    final cityVal = loc['city'] ?? loc['cityId'];
    if (cityVal == null) return '';
    if (cityVal is Map) {
      final name = (cityVal['name'] ?? cityVal['city_name'] ?? cityVal['cityName'] ?? '').toString();
      if (name.isNotEmpty) return name;
      final id = (cityVal['_id'] ?? cityVal['id'])?.toString();
      if (id != null) return _cityNameById[id] ?? id;
      return '';
    }
    return _cityNameById[cityVal.toString()] ?? cityVal.toString();
  }

  Future<void> _loadLocations() async {
    setState(() => _loadingLocations = true);
    try {
      final searchQuery = _locationSearchController.text.trim();
      final list = await _masterDataService.getAllLocationMasters(
        page: _locationPage,
        limit: _limit * 20,
        search: searchQuery.isEmpty ? null : searchQuery,
      );
      final countryIds = <String>{};
      final cityIds = <String>{};
      for (final loc in list) {
        if (loc is! Map) continue;
        final c = loc['country'] ?? loc['countryId'];
        final city = loc['city'] ?? loc['cityId'];
        if (c is Map) {
          final id = (c['_id'] ?? c['id'])?.toString();
          if (id != null && id.isNotEmpty) countryIds.add(id);
        } else if (c != null) countryIds.add(c.toString());
        if (city is Map) {
          final id = (city['_id'] ?? city['id'])?.toString();
          if (id != null && id.isNotEmpty) cityIds.add(id);
        } else if (city != null) cityIds.add(city.toString());
      }
      final countryNameById = <String, String>{};
      final cityNameById = <String, String>{};
      try {
        final countries = await _masterDataService.getAllCountries();
        for (final c in countries) {
          if (c is! Map) continue;
          final id = (c['_id'] ?? c['id'])?.toString() ?? '';
          final name = (c['name'] ?? c['country_name'] ?? c['countryName'] ?? '').toString();
          if (id.isNotEmpty) countryNameById[id] = name;
        }
        for (final countryId in countryIds) {
          final cities = await _masterDataService.getCitiesByCountry(countryId);
          for (final c in cities) {
            if (c is! Map) continue;
            final id = (c['_id'] ?? c['id'])?.toString() ?? '';
            final name = (c['name'] ?? c['city_name'] ?? c['cityName'] ?? '').toString();
            if (id.isNotEmpty) cityNameById[id] = name;
          }
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _allLocations = list;
          _countryNameById.clear();
          _countryNameById.addAll(countryNameById);
          _cityNameById.clear();
          _cityNameById.addAll(cityNameById);
          _loadingLocations = false;
        });
        _applyLocationSearch();
      }
    } catch (e) {
      if (mounted) setState(() => _loadingLocations = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  /// Extract coordinates from various API response shapes (array [lat,lng], GeoJSON, or flat lat/lng).
  String _formatLocationCoordinates(Map<dynamic, dynamic> loc) {
    // location as array [lat, lng] or [lng, lat]
    final locArr = loc['location'];
    if (locArr is List && locArr.length >= 2) {
      final a = locArr[0]?.toString().trim() ?? '';
      final b = locArr[1]?.toString().trim() ?? '';
      if (a.isNotEmpty || b.isNotEmpty) return '$a, $b';
    }
    // GeoJSON: location.coordinates = [lng, lat]
    if (locArr is Map) {
      final coords = locArr['coordinates'];
      if (coords is List && coords.length >= 2) {
        final a = coords[0]?.toString().trim() ?? '';
        final b = coords[1]?.toString().trim() ?? '';
        if (a.isNotEmpty || b.isNotEmpty) return '$a, $b';
      }
    }
    final coordsObj = loc['coordinates'];
    if (coordsObj is Map) {
      final lat = (coordsObj['lat'] ?? coordsObj['latitude'])?.toString().trim() ?? '';
      final lng = (coordsObj['lng'] ?? coordsObj['longitude'])?.toString().trim() ?? '';
      if (lat.isNotEmpty || lng.isNotEmpty) return '$lat, $lng';
    }
    if (coordsObj is List && coordsObj.length >= 2) {
      final a = coordsObj[0]?.toString().trim() ?? '';
      final b = coordsObj[1]?.toString().trim() ?? '';
      if (a.isNotEmpty || b.isNotEmpty) return '$a, $b';
    }
    final lat = loc['latitude']?.toString().trim() ?? '';
    final lng = loc['longitude']?.toString().trim() ?? '';
    if (lat.isNotEmpty || lng.isNotEmpty) return '$lat, $lng';
    return '';
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final list = await _masterDataService.getAllCategories();
      if (mounted) {
        setState(() {
          _allCategories = list is List ? List<dynamic>.from(list) : [];
          _loadingCategories = false;
        });
        _applyCategorySearch();
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCategories = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _applyCategorySearch() {
    final query = _categorySearch.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _categories = List<dynamic>.from(_allCategories));
      return;
    }
    setState(() {
      _categories = _allCategories.where((raw) {
        final cat = raw is Map ? raw as Map : <dynamic, dynamic>{};
        final name = (cat['cName'] ?? cat['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AdminTheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Location'),
            Tab(text: 'Categories'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLocationTab(),
              _buildCategoriesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFilterBar(
            filters: const [],
            searchField: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationSearchController,
                    onSubmitted: (_) => _loadLocations(),
                    decoration: AdminTheme.inputDecoration(
                      context,
                      hintText: 'Search Location…',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _applyLocationSearch,
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Search'),
                  style: AdminTheme.primaryButtonStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: 'Location Master',
            action: FilledButton.icon(
              onPressed: () => _showAddLocationModal(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
              style: AdminTheme.primaryButtonStyle,
            ),
            child: _locations.isEmpty && !_loadingLocations
                ? AdminEmptyState(
                    icon: Icons.location_off,
                    message: 'No locations yet.',
                    actionLabel: 'Add Location',
                    onAction: () => _showAddLocationModal(context),
                  )
                : AdminSimpleTable(
                    columnLabels: const ['S.No', 'Country', 'City', 'Landmark', 'Street Name', 'Coordinates', 'Actions'],
                    rows: _locations.asMap().entries.map((e) {
                      final i = e.key + 1;
                      final loc = e.value as Map;
                      final country = _getLocationCountryDisplay(loc);
                      final city = _getLocationCityDisplay(loc);
                      final landmark = (loc['landmark'] ?? loc['name'] ?? '').toString();
                      final streetName = (loc['streetName'] ?? loc['address'] ?? '').toString();
                      final coords = _formatLocationCoordinates(loc);
                      final locId = (loc['_id'] ?? loc['id'])?.toString() ?? '';
                      return [
                        Text('$i'),
                        Text(country),
                        Text(city),
                        Text(landmark),
                        Text(streetName),
                        Text(coords),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: locId.isEmpty ? null : () => _showEditLocationModal(context, loc)),
                            IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: locId.isEmpty ? null : () => _confirmDeleteLocation(context, loc)),
                          ],
                        ),
                      ];
                    }).toList(),
                    isLoading: _loadingLocations,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFilterBar(
            filters: const [],
            searchField: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() {
                      _categorySearch = v;
                      _applyCategorySearch();
                    }),
                    onSubmitted: (_) => _applyCategorySearch(),
                    decoration: AdminTheme.inputDecoration(
                      context,
                      hintText: 'Search Categories…',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _applyCategorySearch,
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Search'),
                  style: AdminTheme.primaryButtonStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: 'Categories Master',
            action: FilledButton.icon(
              onPressed: () => _showAddCategoryModal(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
              style: AdminTheme.primaryButtonStyle,
            ),
            child: _categories.isEmpty && !_loadingCategories
                ? AdminEmptyState(
                    icon: Icons.category,
                    message: 'No categories yet.',
                    actionLabel: 'Add Category',
                    onAction: () => _showAddCategoryModal(context),
                  )
                : AdminSimpleTable(
                    columnLabels: const ['S.No', 'Name', 'Image', 'Action'],
                    rows: _categories.asMap().entries.map((e) {
                      final i = e.key + 1;
                      final cat = e.value as Map;
                      final name = (cat['cName'] ?? cat['name'] ?? '').toString();
                      final img = cat['image'] ?? cat['media'] ?? '';
                      return [
                        Text('$i'),
                        Text(name),
                        img.toString().isEmpty
                            ? const Icon(Icons.image_not_supported, size: 24)
                            : Image.network(img.toString(), width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showEditCategoryModal(context, cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _confirmDeleteCategory(context, cat),
                            ),
                          ],
                        ),
                      ];
                    }).toList(),
                    isLoading: _loadingCategories,
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLocation(BuildContext context, Map<dynamic, dynamic> loc) async {
    final id = (loc['_id'] ?? loc['id'])?.toString() ?? '';
    if (id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Location'),
        content: const Text('Are you sure you want to delete this location?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _masterDataService.deleteLocationMaster(id);
      if (mounted) {
        _loadLocations();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location deleted')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _showEditLocationModal(BuildContext context, Map<dynamic, dynamic> loc) async {
    final id = (loc['_id'] ?? loc['id'])?.toString() ?? '';
    if (id.isEmpty) return;
    Map<String, dynamic>? full;
    try {
      full = await _masterDataService.getLocationMasterById(id);
    } catch (_) {}
    final data = full ?? Map<String, dynamic>.from(loc);
    String? countryId = (data['country'] is Map) ? ((data['country'] as Map)['_id'] ?? (data['country'] as Map)['id'])?.toString() : data['country']?.toString();
    String? cityId = (data['city'] is Map) ? ((data['city'] as Map)['_id'] ?? (data['city'] as Map)['id'])?.toString() : data['city']?.toString();
    final nameController = TextEditingController(text: (data['landmark'] ?? data['name'] ?? '').toString());
    final addressController = TextEditingController(text: (data['streetName'] ?? data['address'] ?? '').toString());
    double lat = 0.0, lng = 0.0;
    final locArr = data['location'];
    if (locArr is List && locArr.length >= 2) {
      lat = (locArr[0] is num) ? (locArr[0] as num).toDouble() : double.tryParse(locArr[0]?.toString() ?? '') ?? 0.0;
      lng = (locArr[1] is num) ? (locArr[1] as num).toDouble() : double.tryParse(locArr[1]?.toString() ?? '') ?? 0.0;
    } else {
      lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : double.tryParse(data['latitude']?.toString() ?? '') ?? 0.0;
      lng = (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : double.tryParse(data['longitude']?.toString() ?? '') ?? 0.0;
    }
    if (lat == 0.0 && lng == 0.0) { lat = 25.0772; lng = 55.1398; }
    final latController = TextEditingController(text: lat.toString());
    final lngController = TextEditingController(text: lng.toString());
    List<dynamic> countries = [];
    List<dynamic> cities = [];
    try {
      countries = await _masterDataService.getAllCountries();
      if (countryId != null && countryId.isNotEmpty) cities = await _masterDataService.getCitiesByCountry(countryId);
    } catch (_) {}
    // Sort alphabetically by display name
    countries = List<dynamic>.from(countries)
      ..sort((a, b) => ((a['name'] ?? a['country_name'] ?? '').toString().toLowerCase())
          .compareTo((b['name'] ?? b['country_name'] ?? '').toString().toLowerCase()));
    cities = List<dynamic>.from(cities)
      ..sort((a, b) => ((a['name'] ?? a['city_name'] ?? '').toString().toLowerCase())
          .compareTo((b['name'] ?? b['city_name'] ?? '').toString().toLowerCase()));
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final countryList = countries.map((c) => c is Map ? Map<String, dynamic>.from(c as Map) : <String, dynamic>{}).toList();
          final cityList = cities.map((c) => c is Map ? Map<String, dynamic>.from(c as Map) : <String, dynamic>{}).toList();
          return AlertDialog(
            title: const Text('Edit Location'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchableDropdown<Map<String, dynamic>>(
                      label: 'Country *',
                      value: countryId,
                      items: countryList,
                      displayText: (c) => (c['name'] ?? c['country_name'] ?? c['countryName'] ?? '').toString(),
                      getValue: (c) => (c['_id'] ?? c['id'])?.toString() ?? '',
                      onChanged: (v) async {
                        countryId = v;
                        cityId = null;
                        cities = v != null ? await _masterDataService.getCitiesByCountry(v!) : [];
                        cities = List<dynamic>.from(cities)
                          ..sort((a, b) => ((a['name'] ?? a['city_name'] ?? '').toString().toLowerCase())
                              .compareTo((b['name'] ?? b['city_name'] ?? '').toString().toLowerCase()));
                        setModalState(() {});
                      },
                      isRequired: true,
                      prefixIcon: Icons.public,
                      decoration: AdminTheme.dropdownTriggerDecoration(ctx),
                      labelStyle: AdminTheme.dropdownLabelStyle(ctx),
                      valueStyle: AdminTheme.dropdownValueStyle(ctx),
                    ),
                    const SizedBox(height: 12),
                    SearchableDropdown<Map<String, dynamic>>(
                      label: 'City *',
                      value: cityId,
                      items: cityList,
                      displayText: (c) => (c['name'] ?? c['city_name'] ?? c['cityName'] ?? '').toString(),
                      getValue: (c) => (c['_id'] ?? c['id'])?.toString() ?? '',
                      onChanged: (v) => setModalState(() => cityId = v),
                      isRequired: true,
                      prefixIcon: Icons.location_city,
                      decoration: AdminTheme.dropdownTriggerDecoration(ctx),
                      labelStyle: AdminTheme.dropdownLabelStyle(ctx),
                      valueStyle: AdminTheme.dropdownValueStyle(ctx),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Landmark / Name *')),
                    const SizedBox(height: 12),
                    TextField(controller: addressController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Street Name / Address')),
                    const SizedBox(height: 12),
                    TextField(controller: latController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Latitude *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 12),
                    TextField(controller: lngController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Longitude *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                style: AdminTheme.primaryButtonStyle,
                onPressed: () async {
                  if ((countryId?.isEmpty ?? true) || (cityId?.isEmpty ?? true) || nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Country, City and Name are required')));
                    return;
                  }
                  final latVal = double.tryParse(latController.text);
                  final lngVal = double.tryParse(lngController.text);
                  if (latVal == null || lngVal == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid coordinates required')));
                    return;
                  }
                  try {
                    await _masterDataService.updateLocationMaster(
                      id: id,
                      streetName: addressController.text.trim().isEmpty ? nameController.text.trim() : addressController.text.trim(),
                      country: countryId!,
                      city: cityId!,
                      landmark: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                      location: [latVal, lngVal],
                    );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      _loadLocations();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddLocationModal(BuildContext context) async {
    String? countryId;
    String? cityId;
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController(text: '25.0772');
    final lngController = TextEditingController(text: '55.1398');
    List<dynamic> countries = [];
    List<dynamic> cities = [];
    try {
      countries = await _masterDataService.getAllCountries();
    } catch (_) {}
    // Sort countries alphabetically by display name
    countries = List<dynamic>.from(countries)
      ..sort((a, b) => ((a['name'] ?? a['country_name'] ?? '').toString().toLowerCase())
          .compareTo((b['name'] ?? b['country_name'] ?? '').toString().toLowerCase()));

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final countryList = countries.map((c) => c is Map ? Map<String, dynamic>.from(c as Map) : <String, dynamic>{}).toList();
          final cityList = cities.map((c) => c is Map ? Map<String, dynamic>.from(c as Map) : <String, dynamic>{}).toList();
          return AlertDialog(
            title: const Text('Add New Location'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchableDropdown<Map<String, dynamic>>(
                      label: 'Country *',
                      value: countryId,
                      items: countryList,
                      displayText: (c) => (c['name'] ?? c['country_name'] ?? c['countryName'] ?? '').toString(),
                      getValue: (c) => (c['_id'] ?? c['id'])?.toString() ?? '',
                      onChanged: (v) async {
                        countryId = v;
                        cityId = null;
                        cities = v != null ? await _masterDataService.getCitiesByCountry(v!) : [];
                        cities = List<dynamic>.from(cities)
                          ..sort((a, b) => ((a['name'] ?? a['city_name'] ?? '').toString().toLowerCase())
                              .compareTo((b['name'] ?? b['city_name'] ?? '').toString().toLowerCase()));
                        setModalState(() {});
                      },
                      isRequired: true,
                      prefixIcon: Icons.public,
                      decoration: AdminTheme.dropdownTriggerDecoration(ctx),
                      labelStyle: AdminTheme.dropdownLabelStyle(ctx),
                      valueStyle: AdminTheme.dropdownValueStyle(ctx),
                    ),
                    const SizedBox(height: 12),
                    SearchableDropdown<Map<String, dynamic>>(
                      label: 'City *',
                      value: cityId,
                      items: cityList,
                      displayText: (c) => (c['name'] ?? c['city_name'] ?? c['cityName'] ?? '').toString(),
                      getValue: (c) => (c['_id'] ?? c['id'])?.toString() ?? '',
                      onChanged: (v) => setModalState(() => cityId = v),
                      isRequired: true,
                      prefixIcon: Icons.location_city,
                      decoration: AdminTheme.dropdownTriggerDecoration(ctx),
                      labelStyle: AdminTheme.dropdownLabelStyle(ctx),
                      valueStyle: AdminTheme.dropdownValueStyle(ctx),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Landmark / Name *')),
                    const SizedBox(height: 12),
                    TextField(controller: addressController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Street Name / Address')),
                    const SizedBox(height: 12),
                    TextField(controller: latController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Latitude *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 12),
                    TextField(controller: lngController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Longitude *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                style: AdminTheme.primaryButtonStyle,
                onPressed: () async {
                  if (countryId == null || cityId == null || nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Country, City and Name are required')));
                    return;
                  }
                  final lat = double.tryParse(latController.text);
                  final lng = double.tryParse(lngController.text);
                  if (lat == null || lng == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid coordinates required')));
                    return;
                  }
                  try {
                    await _masterDataService.createLocationMaster(
                      streetName: addressController.text.trim().isEmpty ? nameController.text.trim() : addressController.text.trim(),
                      country: countryId!,
                      city: cityId!,
                      landmark: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                      location: [lat, lng],
                    );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      _loadLocations();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location created')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, Map<dynamic, dynamic> cat) async {
    final id = (cat['_id'] ?? cat['id'])?.toString() ?? '';
    if (id.isEmpty) return;
    final name = (cat['cName'] ?? cat['name'] ?? 'Category').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _masterDataService.deleteCategory(id);
      if (mounted) {
        _loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _showEditCategoryModal(BuildContext context, Map<dynamic, dynamic> cat) {
    final id = (cat['_id'] ?? cat['id'])?.toString() ?? '';
    if (id.isEmpty) return;
    final nameController = TextEditingController(text: (cat['cName'] ?? cat['name'] ?? '').toString());
    final descController = TextEditingController(text: (cat['description'] ?? '').toString());
    File? imageFile;
    final existingImageUrl = cat['image'] ?? cat['media'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(source: ImageSource.gallery);
                        if (x != null && mounted) setModalState(() => imageFile = File(x.path));
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(imageFile != null ? 'Image selected' : (existingImageUrl.toString().isEmpty ? 'Upload Image' : 'Change Image')),
                    ),
                    if (existingImageUrl.toString().isNotEmpty && imageFile == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.network(existingImageUrl.toString(), width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                      ),
                    const SizedBox(height: 12),
                    TextField(controller: nameController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Category Name *')),
                    const SizedBox(height: 12),
                    TextField(controller: descController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Description *'), maxLines: 3),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                style: AdminTheme.primaryButtonStyle,
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category name is required')));
                    return;
                  }
                  try {
                    await _masterDataService.updateCategory(
                      id: id,
                      name: nameController.text.trim(),
                      description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                      image: imageFile,
                    );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      _loadCategories();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category updated')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCategoryModal(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    File? imageFile;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return AlertDialog(
            title: const Text('Add New Category'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(source: ImageSource.gallery);
                        if (x != null && mounted) setModalState(() => imageFile = File(x.path));
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(imageFile == null ? 'Upload Image' : 'Image selected'),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Category Name *')),
                    const SizedBox(height: 12),
                    TextField(controller: descController, decoration: AdminTheme.inputDecoration(ctx, labelText: 'Description *'), maxLines: 3),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                style: AdminTheme.primaryButtonStyle,
                onPressed: () async {
                  if (nameController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Description are required')));
                    return;
                  }
                  try {
                    await _masterDataService.createCategory(
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                      image: imageFile,
                    );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      _loadCategories();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category created')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
