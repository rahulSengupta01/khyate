import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/package_service.dart';

class PackageManager extends StatefulWidget {
  @override
  State<PackageManager> createState() => _PackageManagerState();
}

class _PackageManagerState extends State<PackageManager> {
  final _packageService = PackageService();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _numberOfClassesController = TextEditingController();
  final _durationController = TextEditingController(); // Duration in days (number)
  final _searchController = TextEditingController();
  
  File? _selectedImage;
  List<dynamic> _packages = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  
  // Features list for the package
  final List<TextEditingController> _featureControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    _loadPackages();
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
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (mounted) {
        setState(() {
          _packages = _parsePackagesFromResult(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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
    // Validate required fields
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _numberOfClassesController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate duration is a valid number
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration in days')),
      );
      return;
    }

    // Validate price
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    // Validate number of classes
    final classesIncluded = int.tryParse(_numberOfClassesController.text);
    if (classesIncluded == null || classesIncluded <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of classes')),
      );
      return;
    }

    // Validate features
    final features = _featureControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    if (features.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one feature')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _packageService.createPackage(
        image: _selectedImage,
        name: _nameController.text,
        features: features,
        price: price,
        duration: duration, // Duration in days (number)
        classesIncluded: classesIncluded, // API field name: classesIncluded
        isActive: true,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package created successfully')),
        );
        
        // Reset form
        _nameController.clear();
        _priceController.clear();
        _numberOfClassesController.clear();
        _durationController.clear();
        _featureControllers.forEach((controller) => controller.dispose());
        _featureControllers.clear();
        _featureControllers.add(TextEditingController());
        setState(() {
          _selectedImage = null;
        });
        _loadPackages();
        Navigator.pop(context); // Close dialog
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
    _durationController.clear();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    _featureControllers.clear();
    _featureControllers.add(TextEditingController());
    setState(() {
      _selectedImage = null;
    });
  }

  void _showCreateDialog() {
    _resetForm();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Membership',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _resetForm();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Upload Image Section
                    const Text(
                      'Upload Image *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setDialogState(() {
                            _selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (pickedFile != null) {
                                        setDialogState(() {
                                          _selectedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Choose File'),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No file chosen',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Package Name
                    const Text(
                      'Package Name *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter package name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Price, No. of Classes, Duration in horizontal layout
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price *',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter price',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'No. of Classes *',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _numberOfClassesController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter number of classes',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Duration (Days) *',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _durationController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter duration in days',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Features Section
                    const Text(
                      'Features *',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_featureControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _featureControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Feature ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (index == _featureControllers.length - 1)
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.teal),
                                onPressed: () {
                                  setDialogState(() {
                                    _featureControllers.add(TextEditingController());
                                  });
                                },
                              ),
                            if (_featureControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setDialogState(() {
                                    _featureControllers[index].dispose();
                                    _featureControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            _resetForm();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            side: const BorderSide(color: Colors.teal),
                          ),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createPackage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: editImage != null
                        ? Image.file(editImage!, fit: BoxFit.cover)
                        : editImageUrl != null
                            ? Image.network(editImageUrl!, fit: BoxFit.cover)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48),
                                  SizedBox(height: 8),
                                  Text('Tap to select image'),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Package Button
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Membership Packages',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Membership'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loadPackages,
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _packages.isEmpty
                          ? const Center(child: Text('No packages found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _packages.length,
                              itemBuilder: (context, index) {
                                final package = _packages[index];
                                return ListTile(
                                  title: Text(package['name'] ?? 'Unknown'),
                                  subtitle: Text('Price: ${package['price'] ?? 'N/A'} | Duration: ${package['duration'] ?? 'N/A'} days'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditDialog(package),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deletePackage(package),
                                      ),
                                    ],
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
    _nameController.dispose();
    _priceController.dispose();
    _numberOfClassesController.dispose();
    _durationController.dispose();
    _searchController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

