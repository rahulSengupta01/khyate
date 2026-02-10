import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/package_service.dart';
import '../../widgets/admin/admin_theme.dart';

class PackageManager extends StatefulWidget {
  @override
  State<PackageManager> createState() => _PackageManagerState();
}

class _PackageManagerState extends State<PackageManager> {
  final _packageService = PackageService();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _numberOfClassesController = TextEditingController();
  final _searchController = TextEditingController();
  
  /// Duration: "daily" | "weekly" | "monthly" (required by API)
  String? _selectedDuration = 'monthly';
  
  File? _selectedImage;
  List<dynamic> _allPackages = [];
  List<dynamic> _packages = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  
  // Features list for the package (optional per API)
  final List<TextEditingController> _featureControllers = [TextEditingController()];
  
  static const List<String> _durationOptions = ['daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _searchController.addListener(_applySearchFilter);
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _packages = List<dynamic>.from(_allPackages));
      return;
    }
    setState(() {
      _packages = _allPackages.where((raw) {
        final p = raw is Map ? Map<String, dynamic>.from(raw.map((k, v) => MapEntry(k.toString(), v))) : <String, dynamic>{};
        final name = (p['name']?.toString() ?? '').toLowerCase();
        final price = (p['price']?.toString() ?? '').toLowerCase();
        final duration = (p['duration']?.toString() ?? '').toLowerCase();
        final desc = (p['description']?.toString() ?? '').toLowerCase();
        return name.contains(query) || price.contains(query) || duration.contains(query) || desc.contains(query);
      }).toList();
    });
  }

  /// Parse packages from API result - same structure as membership_carousel.
  List<dynamic> _parsePackagesFromResult(dynamic result) {
    if (result == null) return [];
    final r = result;
    if (r is List) return List<dynamic>.from(r);
    if (r is! Map) return [];
    if (r['packages'] is List) return List<dynamic>.from(r['packages'] as List);
    if (r['data'] is List) return List<dynamic>.from(r['data'] as List);
    if (r['data'] is Map) {
      final dataMap = r['data'] as Map;
      if (dataMap['packages'] is List) return List<dynamic>.from(dataMap['packages'] as List);
    }
    return [];
  }

  Future<void> _loadPackages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Use same call as membership carousel: higher limit to get all packages
      final result = await _packageService.getAllPackages(
        page: _page,
        limit: 100,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _allPackages = _parsePackagesFromResult(result);
          _isLoading = false;
        });
        _applySearchFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allPackages = [];
          _packages = [];
          _isLoading = false;
        });
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        if (errorMsg.contains('Failed to load packages:')) {
          errorMsg = errorMsg.replaceFirst('Failed to load packages: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load packages. $errorMsg Tap refresh to retry.'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadPackages,
            ),
          ),
        );
      }
    }
  }


  Future<void> _createPackage() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _numberOfClassesController.text.trim().isEmpty ||
        _selectedDuration == null ||
        _selectedDuration!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (name, price, number of classes, duration)')),
      );
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }
    final numberOfClasses = int.tryParse(_numberOfClassesController.text.trim());
    if (numberOfClasses == null || numberOfClasses <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of classes')),
      );
      return;
    }
    final features = _featureControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _packageService.createPackage(
        image: _selectedImage,
        name: _nameController.text.trim(),
        features: features.isEmpty ? null : features,
        price: price,
        duration: _selectedDuration!,
        numberOfClasses: numberOfClasses,
        isActive: true,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package created successfully')),
        );
        _nameController.clear();
        _priceController.clear();
        _numberOfClassesController.clear();
        setState(() => _selectedDuration = 'monthly');
        _featureControllers.forEach((c) => c.dispose());
        _featureControllers.clear();
        _featureControllers.add(TextEditingController());
        setState(() => _selectedImage = null);
        _loadPackages();
      }
    } catch (e) {
      if (mounted) {
        // Extract clean error message
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        if (errorMsg.contains('Failed to create package:')) {
          errorMsg = errorMsg.replaceFirst('Failed to create package: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating package: $errorMsg'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _numberOfClassesController.clear();
    setState(() {
      _selectedDuration = 'monthly';
      _selectedImage = null;
    });
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    _featureControllers.clear();
    _featureControllers.add(TextEditingController());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _deletePackage(Map<String, dynamic> package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "${package['name'] ?? 'this package'}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      try {
        await _packageService.deletePackage(
          packageId: package['_id'] ?? package['id'] ?? '',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package deleted successfully')),
          );
          _loadPackages();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting package: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> package) async {
    final editNameController = TextEditingController(text: package['name'] ?? '');
    final editPriceController = TextEditingController(text: package['price']?.toString() ?? '');
    File? editImage;
    String? editImageUrl = package['image'] ?? package['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        editImage = File(pickedFile.path);
                        editImageUrl = null;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: AdminTheme.uploadSectionDecoration(context),
                    child: editImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(editImage!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: AdminTheme.editOverlayColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                      if (pickedFile != null) {
                                        setDialogState(() {
                                          editImage = File(pickedFile.path);
                                          editImageUrl = null;
                                        });
                                      }
                                    },
                                    padding: const EdgeInsets.all(6),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : editImageUrl != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(editImageUrl!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Material(
                                      color: AdminTheme.editOverlayColor(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            setDialogState(() {
                                              editImage = File(pickedFile.path);
                                              editImageUrl = null;
                                            });
                                          }
                                        },
                                        padding: const EdgeInsets.all(6),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48, color: AdminTheme.fieldTextMuted(context)),
                                  const SizedBox(height: 8),
                                  Text('Tap to select image', style: TextStyle(color: AdminTheme.fieldTextMuted(context))),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editNameController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editPriceController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _packageService.updatePackage(
                    packageId: package['_id'] ?? package['id'] ?? '',
                    image: editImage,
                    name: editNameController.text.isEmpty
                        ? null
                        : editNameController.text,
                    price: editPriceController.text.isEmpty
                        ? null
                        : double.tryParse(editPriceController.text),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Package updated successfully')),
                    );
                    _loadPackages();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Membership card - inline form like Programs
          Container(
            decoration: AdminTheme.formCardDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AdminTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.card_membership, color: AdminTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Membership',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add a new membership package',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: AdminTheme.uploadSectionDecoration(context),
                      child: _selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: AdminTheme.editOverlayColor(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                      onPressed: _pickImage,
                                      padding: const EdgeInsets.all(6),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: AdminTheme.fieldTextMuted(context)),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to select image',
                                  style: TextStyle(fontSize: 16, color: AdminTheme.fieldTextMuted(context)),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Package Name *', prefixIcon: Icon(Icons.title, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Price *', prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _numberOfClassesController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'No. of Classes *', prefixIcon: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Duration *', prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      items: _durationOptions
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d[0].toUpperCase() + d.substring(1)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDuration = v),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.list, color: AdminTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Features',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AdminTheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_featureControllers.length} feature${_featureControllers.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: AdminTheme.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_featureControllers.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _featureControllers[index],
                                    decoration: AdminTheme.inputDecoration(context, hintText: 'Feature ${index + 1}', isDense: true),
                                  ),
                                ),
                                if (index == _featureControllers.length - 1)
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: AdminTheme.primary),
                                    onPressed: () {
                                      setState(() {
                                        _featureControllers.add(TextEditingController());
                                      });
                                    },
                                    tooltip: 'Add feature',
                                  ),
                                if (_featureControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _featureControllers[index].dispose();
                                        _featureControllers.removeAt(index);
                                      });
                                    },
                                    tooltip: 'Remove',
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _createPackage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_circle, size: 20),
                      label: Text(
                        _isLoading ? 'Creating...' : 'Create Membership',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: AdminTheme.primaryButtonStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Membership list card - same style as Programs list
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AdminTheme.cardBgDark : AdminTheme.cardBgTint,
              borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
              border: Border.all(color: AdminTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AdminTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.list, color: AdminTheme.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Membership List',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View and manage all membership packages',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: AdminTheme.inputDecoration(
                            context,
                            labelText: 'Search membership...',
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _applySearchFilter,
                        icon: const Icon(Icons.search, size: 20),
                        label: const Text('Search'),
                        style: AdminTheme.primaryButtonStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _packages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.card_membership, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No membership packages found',
                                      style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _packages.length,
                                itemBuilder: (context, index) {
                                  final package = _packages[index];
                                  final imageUrl = package['image'] ?? package['imageUrl'];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: AdminTheme.primary.withOpacity(0.15),
                                        ),
                                        child: imageUrl != null && imageUrl.toString().isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  imageUrl.toString(),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Icon(Icons.card_membership, color: AdminTheme.primary),
                                                ),
                                              )
                                            : Icon(Icons.card_membership, color: AdminTheme.primary),
                                      ),
                                      title: Text(
                                        package['name'] ?? 'Unknown',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Price: AED ${package['price'] ?? 'N/A'}${package['duration'] != null ? ' • ${package['duration']}' : ''}',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showEditDialog(package),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deletePackage(package),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearchFilter);
    _nameController.dispose();
    _priceController.dispose();
    _numberOfClassesController.dispose();
    _searchController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

