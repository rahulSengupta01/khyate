import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/admin/admin_theme.dart';
import '../../../widgets/admin/admin_section_card.dart';
import '../../../widgets/admin/admin_filter_bar.dart';
import '../../../widgets/admin/admin_simple_table.dart';
import '../../../widgets/admin/admin_modal_form.dart';
import '../../../widgets/admin/admin_empty_state.dart';
import '../../../services/master_data_service.dart';

class MastersSection extends StatefulWidget {
  const MastersSection({super.key});

  @override
  State<MastersSection> createState() => _MastersSectionState();
}

class _MastersSectionState extends State<MastersSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _masterDataService = MasterDataService();
  List<dynamic> _locations = [];
  List<dynamic> _categories = [];
  bool _loadingLocations = false;
  bool _loadingCategories = false;
  String _locationSearch = '';
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
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    setState(() => _loadingLocations = true);
    try {
      final list = await _masterDataService.getAllLocationMasters(
        page: _locationPage,
        limit: _limit,
        search: _locationSearch.isEmpty ? null : _locationSearch,
      );
      if (mounted) setState(() { _locations = list; _loadingLocations = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingLocations = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final list = await _masterDataService.getAllCategories();
      if (mounted) setState(() { _categories = list is List ? list : []; _loadingCategories = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingCategories = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
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
            searchField: TextField(
              onChanged: (v) => setState(() => _locationSearch = v),
              onSubmitted: (_) => _loadLocations(),
              decoration: const InputDecoration(
                hintText: 'Search Location…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: 'Location Master',
            action: FilledButton.icon(
              onPressed: () => _showAddLocationModal(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Location'),
              style: FilledButton.styleFrom(backgroundColor: AdminTheme.primary),
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
                      final country = loc['country'] is Map ? (loc['country'] as Map)['name'] ?? '' : '';
                      final city = loc['city'] is Map ? (loc['city'] as Map)['name'] ?? '' : '';
                      final lat = loc['latitude']?.toString() ?? '';
                      final lng = loc['longitude']?.toString() ?? '';
                      final coords = '$lat, $lng';
                      return [
                        Text('$i'),
                        Text(country.toString()),
                        Text(city.toString()),
                        Text((loc['name'] ?? '').toString()),
                        Text((loc['address'] ?? '').toString()),
                        Text(coords),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () {}),
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
            searchField: TextField(
              onChanged: (v) => setState(() => _categorySearch = v),
              decoration: const InputDecoration(
                hintText: 'Search Categories…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: 'Categories Master',
            action: FilledButton.icon(
              onPressed: () => _showAddCategoryModal(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Category'),
              style: FilledButton.styleFrom(backgroundColor: AdminTheme.primary),
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
                            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () {}),
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

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return AlertDialog(
            title: const Text('Add New Location'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: countryId,
                      decoration: const InputDecoration(labelText: 'Country *'),
                      items: countries.map((c) {
                        final id = (c['_id'] ?? c['id']).toString();
                        final n = (c['name'] ?? c['country_name'] ?? '').toString();
                        return DropdownMenuItem(value: id, child: Text(n));
                      }).toList(),
                      onChanged: (v) async {
                        countryId = v;
                        cities = v != null ? await _masterDataService.getCitiesByCountry(v) : [];
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: cityId,
                      decoration: const InputDecoration(labelText: 'City *'),
                      items: cities.map((c) {
                        final id = (c['_id'] ?? c['id']).toString();
                        final n = (c['name'] ?? c['city_name'] ?? '').toString();
                        return DropdownMenuItem(value: id, child: Text(n));
                      }).toList(),
                      onChanged: (v) => setModalState(() => cityId = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Landmark / Name *')),
                    const SizedBox(height: 12),
                    TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Street Name / Address')),
                    const SizedBox(height: 12),
                    TextField(controller: latController, decoration: const InputDecoration(labelText: 'Latitude *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 12),
                    TextField(controller: lngController, decoration: const InputDecoration(labelText: 'Longitude *'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
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
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Category Name *')),
                    const SizedBox(height: 12),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description *'), maxLines: 3),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
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
