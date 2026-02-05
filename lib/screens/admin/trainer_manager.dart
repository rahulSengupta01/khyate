import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/trainer_service.dart';
import '../../services/master_data_service.dart';
import '../../widgets/searchable_dropdown.dart';
import '../../widgets/admin/admin_theme.dart';

class TrainerManager extends StatefulWidget {
  @override
  State<TrainerManager> createState() => _TrainerManagerState();
}

class _TrainerManagerState extends State<TrainerManager> {
  final _trainerService = TrainerService();
  final _masterDataService = MasterDataService();
  
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _specializationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emiratesIdController = TextEditingController();
  
  File? _selectedImage;
  File? _idProofFile;
  File? _certificatesFile;
  String? _selectedGender;
  String? _selectedExperience; // Backend enum: EXPERIENCE | FRESHER
  String? _selectedCountry;
  String? _selectedCity;
  List<String> _selectedServiceProviders = [];
  
  List<dynamic> _countries = [];
  List<dynamic> _cities = [];
  List<dynamic> _serviceTypes = [];
  List<dynamic> _trainers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadServiceTypes();
    _loadTrainers();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _masterDataService.getAllCountries();
      setState(() {
        _countries = countries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading countries: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadCities(String countryId) async {
    try {
      final cities = await _masterDataService.getCitiesByCountry(countryId);
      setState(() {
        _cities = cities;
        _selectedCity = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cities: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadServiceTypes() async {
    try {
      final services = await _masterDataService.getAllCustomerServices();
      setState(() {
        _serviceTypes = services;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadTrainers() async {
    try {
      final trainers = await _trainerService.getAllTrainers();
      if (!mounted) return;
      setState(() {
        _trainers = trainers;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trainers: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickIdProof() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idProofFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _certificatesFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addTrainer() async {
    // Capture values once so we send exactly what the user entered
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final address = _addressController.text.trim();
    final specialization = _specializationController.text.trim();
    final emiratesId = _emiratesIdController.text.trim();

    if (email.isEmpty ||
        firstName.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        emiratesId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields: Email, First Name, Phone Number, Password, Emirates ID.')),
      );
      return;
    }
    final ageVal = int.tryParse(_ageController.text.trim());

    setState(() => _isLoading = true);
    try {
      // Resolve service provider IDs to names for API (expects e.g. ["Personal Training", "Group Fitness"])
      final serviceProviderNames = _selectedServiceProviders.isEmpty
          ? null
          : _serviceTypes
              .where((s) {
                final id = s['_id']?.toString() ?? s['id']?.toString();
                return id != null && _selectedServiceProviders.contains(id);
              })
              .map((s) => s['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList();

      await _trainerService.createTrainer(
        profileImage: _selectedImage,
        idProof: _idProofFile,
        certificate: _certificatesFile,
        email: email,
        firstName: firstName,
        lastName: lastName.isEmpty ? null : lastName,
        phoneNumber: phoneNumber,
        emiratesId: emiratesId,
        gender: _selectedGender,
        address: address.isEmpty ? null : address,
        age: ageVal != null && ageVal > 0 ? ageVal : null,
        country: _selectedCountry,
        city: _selectedCity,
        specialization: specialization.isEmpty ? null : specialization,
        experience: _selectedExperience,
        experienceYear: null,
        password: password,
        serviceProvider: serviceProviderNames?.isEmpty == true ? null : serviceProviderNames,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trainer created successfully')),
      );
      
      _emailController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _emiratesIdController.clear();
      _addressController.clear();
      _ageController.clear();
      _specializationController.clear();
      _passwordController.clear();
      _selectedImage = null;
      _idProofFile = null;
      _certificatesFile = null;
      _selectedGender = null;
      _selectedCountry = null;
      _selectedCity = null;
      _selectedServiceProviders = [];
      await _loadTrainers();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating trainer: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTrainerStatus(String trainerId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    setState(() => _isLoading = true);
    try {
      await _trainerService.updateTrainerStatus(
        trainerId: trainerId,
        status: newStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trainer status updated to $newStatus')),
      );
      await _loadTrainers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> trainer) async {
    final editFirstNameController = TextEditingController(text: trainer['first_name'] ?? '');
    final editLastNameController = TextEditingController(text: trainer['last_name'] ?? '');
    final editSpecializationController = TextEditingController(text: trainer['specialization'] ?? '');
    File? editImage;
    String? editImageUrl = trainer['profile_image'] ?? trainer['imageUrl'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Trainer'),
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
                  controller: editFirstNameController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'First Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editLastNameController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Last Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editSpecializationController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Specialization'),
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
                  await _trainerService.updateTrainer(
                    trainerId: trainer['_id'] ?? trainer['id'] ?? '',
                    profileImage: editImage,
                    firstName: editFirstNameController.text.isEmpty
                        ? null
                        : editFirstNameController.text,
                    lastName: editLastNameController.text.isEmpty
                        ? null
                        : editLastNameController.text,
                    specialization: editSpecializationController.text.isEmpty
                        ? null
                        : editSpecializationController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trainer updated successfully')),
                    );
                    await _loadTrainers();
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

  Future<void> _delete(String id) async {
    if (id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete trainer'),
        content: const Text(
          'Are you sure you want to delete this trainer? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await _trainerService.deleteTrainer(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trainer deleted successfully')),
      );
      await _loadTrainers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting trainer: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _inputForm(),
                const SizedBox(height: 24),
                // Trainers List Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Theme.of(context).brightness == Brightness.dark ? AdminTheme.cardBgDark : AdminTheme.cardBgTint,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminTheme.primary.withOpacity(0.2), width: 1),
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
                                child: Icon(Icons.people, color: AdminTheme.primary, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trainers List',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'View and manage all trainers',
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
                          _trainers.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No trainers found',
                                          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _trainers.length,
                        itemBuilder: (context, i) {
                          final trainer = _trainers[i];
                          final status = trainer['userStatus'] ?? trainer['status'] ?? 'inactive';
                          final isActive = status == 'active';
                          final scheme = Theme.of(context).colorScheme;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            color: scheme.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage: trainer['profile_image'] != null
                                    ? NetworkImage(trainer['profile_image'])
                                    : null,
                                backgroundColor: scheme.primaryContainer,
                                child: trainer['profile_image'] == null
                                    ? Icon(Icons.person, color: scheme.onPrimaryContainer)
                                    : null,
                              ),
                              title: Text(
                                '${trainer['first_name'] ?? ''} ${trainer['last_name'] ?? ''}'.trim(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: scheme.onSurface),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (trainer['specialization'] != null)
                                      Text(
                                        trainer['specialization'],
                                        style: TextStyle(color: scheme.onSurfaceVariant),
                                      ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? AdminTheme.success.withOpacity(0.15) : scheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isActive ? null : Border.all(color: scheme.outlineVariant),
                                      ),
                                      child: Text(
                                        'Status: ${status.toUpperCase()}',
                                        style: TextStyle(
                                          color: isActive ? AdminTheme.success : scheme.onSurfaceVariant,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: scheme.primary),
                                  onPressed: () => _showEditDialog(trainer),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: scheme.error),
                                  onPressed: () => _delete(trainer['_id'] ?? trainer['id'] ?? ''),
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
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputForm() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
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
                  child: Icon(Icons.person_add, color: AdminTheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Trainer',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a new trainer to the system',
                        style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 24),
            // Required: email, first_name, emirates_id, phone_number, password. Optional: files and rest.
            // Add Photo / Upload Photo
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
                          const SizedBox(height: 8),
                          Text('Add Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.fieldText(context))),
                          const SizedBox(height: 4),
                          Text('Upload Photo', style: TextStyle(fontSize: 14, color: AdminTheme.fieldTextMuted(context))),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFileUploadRow(
              label: 'ID proof (optional)',
              file: _idProofFile,
              onTap: _pickIdProof,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildFileUploadRow(
              label: 'Certificate (optional)',
              file: _certificatesFile,
              onTap: _pickCertificate,
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _field(_firstNameController, "First Name *", icon: Icons.badge, hintText: 'Enter First Name')),
                const SizedBox(width: 12),
                Expanded(child: _field(_lastNameController, "Last Name", icon: Icons.badge_outlined, hintText: 'Enter Last Name')),
              ],
            ),
            const SizedBox(height: 16),
            _field(_emailController, "Email *", keyboardType: TextInputType.emailAddress, icon: Icons.email, hintText: 'Enter Email'),
            const SizedBox(height: 16),
            _field(_phoneController, "Phone Number *", keyboardType: TextInputType.phone, icon: Icons.phone, hintText: 'Enter phone number with country code'),
            const SizedBox(height: 16),
            _field(_emiratesIdController, "Emirates ID *", keyboardType: TextInputType.text, icon: Icons.badge, hintText: 'Enter Emirates ID'),
            const SizedBox(height: 16),
            _field(_addressController, "Address", icon: Icons.location_on, hintText: 'Enter Address'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Others', child: Text('Others')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_ageController, "Age", keyboardType: TextInputType.number, icon: Icons.cake, hintText: 'Enter age'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Country Dropdown with Search
            _countries.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(AdminTheme.radiusButton),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.public, color: onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text('Loading countries...', style: TextStyle(color: onSurfaceVariant)),
                      ],
                    ),
                  )
                : SearchableDropdown<Map<String, dynamic>>(
                    label: 'Country',
                    value: _selectedCountry,
                    items: _countries.map((c) => c as Map<String, dynamic>).toList(),
                    displayText: (country) => country['name']?.toString() ?? 'Unknown',
                    getValue: (country) {
                      final id = country['_id'] ?? country['id'];
                      return id?.toString() ?? '';
                    },
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _selectedCity = null;
                });
                      if (value != null && value.isNotEmpty) {
                  _loadCities(value);
                }
              },
                    isRequired: false,
                    prefixIcon: Icons.public,
                    decoration: AdminTheme.dropdownTriggerDecoration(context),
                    labelStyle: AdminTheme.dropdownLabelStyle(context),
                    valueStyle: AdminTheme.dropdownValueStyle(context),
            ),
            const SizedBox(height: 16),
            // City Dropdown with Search
            _selectedCountry == null
                ? const SizedBox()
                : _cities.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: AdminTheme.dropdownTriggerDecoration(context),
                        child: Row(
                          children: [
                            Icon(Icons.location_city, color: AdminTheme.fieldTextMuted(context)),
                            const SizedBox(width: 12),
                            Text('Loading cities...', style: TextStyle(color: AdminTheme.fieldTextMuted(context))),
                          ],
                        ),
                      )
                    : SearchableDropdown<Map<String, dynamic>>(
                        label: 'City',
                    value: _selectedCity,
                        items: _cities.map((c) => c as Map<String, dynamic>).toList(),
                        displayText: (city) => city['name']?.toString() ?? 'Unknown',
                        getValue: (city) {
                          final id = city['_id'] ?? city['id'];
                          return id?.toString() ?? '';
                        },
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                        isRequired: false,
                        prefixIcon: Icons.location_city,
                        decoration: AdminTheme.dropdownTriggerDecoration(context),
                        labelStyle: AdminTheme.dropdownLabelStyle(context),
                        valueStyle: AdminTheme.dropdownValueStyle(context),
                  ),
            const SizedBox(height: 24),
            _field(_passwordController, "Password *", obscureText: true, icon: Icons.lock_outline, hintText: 'Enter your password'),
            const SizedBox(height: 16),
            _field(_specializationController, "Specialization", icon: Icons.fitness_center, hintText: 'e.g. Yoga, Fitness'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedExperience,
              decoration: AdminTheme.inputDecoration(context, labelText: 'Experience'),
              items: const [
                DropdownMenuItem(value: 'EXPERIENCE', child: Text('Experienced')),
                DropdownMenuItem(value: 'FRESHER', child: Text('Fresher')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedExperience = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Service Providers Multi-select
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
                      Icon(Icons.category, color: AdminTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Service Providers",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
            Wrap(
              spacing: 8,
                    runSpacing: 8,
              children: _serviceTypes.map((service) {
                final serviceId = service['_id']?.toString() ?? service['id']?.toString();
                if (serviceId == null) return const SizedBox.shrink();
                final isSelected = _selectedServiceProviders.contains(serviceId);
                return FilterChip(
                  label: Text(service['name'] ?? 'Unknown'),
                  selected: isSelected,
                  selectedColor: AdminTheme.primary.withOpacity(0.3),
                  checkmarkColor: AdminTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AdminTheme.primaryDark : onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedServiceProviders.add(serviceId);
                      } else {
                        _selectedServiceProviders.remove(serviceId);
                      }
                    });
                  },
                );
              }).toList(),
            ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _addTrainer,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.person_add, size: 20),
                label: Text(
                  _isLoading ? 'Creating...' : 'Create Trainer',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: AdminTheme.primaryButtonStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadRow({
    required String label,
    required File? file,
    required VoidCallback onTap,
    IconData icon = Icons.attach_file,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(icon, color: onSurfaceVariant, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? file.path.split(RegExp(r'[/\\]')).last : 'No file chosen',
                    style: TextStyle(
                      fontSize: 16,
                      color: file != null ? onSurface : onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.upload_file, color: onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboardType, bool obscureText = false, IconData? icon, String? hintText}) {
    return TextField(
      controller: c,
      decoration: AdminTheme.inputDecoration(
        context,
        labelText: label,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emiratesIdController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _specializationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
