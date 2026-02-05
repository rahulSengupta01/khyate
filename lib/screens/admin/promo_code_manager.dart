import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/admin_service.dart';
import '../../widgets/admin/admin_theme.dart';

class PromoCodeManager extends StatefulWidget {
  @override
  State<PromoCodeManager> createState() => _PromoCodeManagerState();
}

class _PromoCodeManagerState extends State<PromoCodeManager> {
  final _adminService = AdminService();
  
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _maxDiscountAmountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _termsAndConditionsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _applyOfferAfterOrdersController = TextEditingController();
  final _searchController = TextEditingController();
  
  File? _selectedImage;
  String? _selectedDiscountType = 'percentage';
  bool _isActive = true;
  List<dynamic> _promoCodes = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadPromoCodes();
  }

  Future<void> _loadPromoCodes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _adminService.getAllPromoCodes();
      final list = result['promoCodes'] is List
          ? List<dynamic>.from(result['promoCodes'] as List)
          : <dynamic>[];
      if (!mounted) return;
      setState(() {
        _promoCodes = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e.toString()
          .replaceFirst(RegExp(r'^Exception:\s*'), '')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();
      final display = msg.length > 120 ? '${msg.substring(0, 120)}…' : msg;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(display.isEmpty ? 'Error loading promo codes' : 'Error: $display')),
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

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> promo) async {
    final editDiscountValueController = TextEditingController(
      text: (promo['discountValue']?.toString() ?? '').trim(),
    );
    final editValidToController = TextEditingController(
      text: (promo['validTo'] ?? promo['endDate'] ?? '').toString().trim(),
    );
    File? editImage;
    final imageVal = promo['image'] ?? promo['imageUrl'];
    String? editImageUrl = imageVal is String ? imageVal : imageVal?.toString();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Promo Code'),
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
                  controller: editDiscountValueController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Discount Value'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: editValidToController,
                  decoration: AdminTheme.inputDecoration(context, labelText: 'Valid To'),
                  readOnly: true,
                  onTap: () => _pickDate(editValidToController),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: AdminTheme.primaryButtonStyle,
              onPressed: () async {
                try {
                  await _adminService.updatePromoCode(
                    promoCodeId: promo['_id'] ?? promo['id'] ?? '',
                    image: editImage,
                    discountValue: editDiscountValueController.text.isEmpty
                        ? null
                        : double.tryParse(editDiscountValueController.text),
                    endDate: editValidToController.text.isEmpty
                        ? null
                        : editValidToController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Promo code updated successfully')),
                    );
                    _loadPromoCodes();
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

  Future<void> _createPromoCode() async {
    final code = _codeController.text.trim();
    final discountValueStr = _discountValueController.text.trim();
    final maxUsesStr = _maxUsesController.text.trim();
    final terms = _termsAndConditionsController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promo code')),
      );
      return;
    }
    if (discountValueStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter discount value')),
      );
      return;
    }
    final discountValue = double.tryParse(discountValueStr);
    if (discountValue == null || discountValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid discount value (number ≥ 0)')),
      );
      return;
    }
    if (maxUsesStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter max uses')),
      );
      return;
    }
    final maxUses = int.tryParse(maxUsesStr);
    if (maxUses == null || maxUses < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid max uses (integer ≥ 1)')),
      );
      return;
    }
    if (terms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter terms & conditions')),
      );
      return;
    }

    final minOrder = _minOrderAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_minOrderAmountController.text.trim());
    final maxDiscount = _maxDiscountAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxDiscountAmountController.text.trim());
    final applyAfter = _applyOfferAfterOrdersController.text.trim().isEmpty
        ? null
        : int.tryParse(_applyOfferAfterOrdersController.text.trim());

    setState(() => _isLoading = true);
    try {
      await _adminService.createPromoCode(
        image: _selectedImage,
        imageUrl: null,
        code: code,
        discountType: _selectedDiscountType ?? 'percentage',
        discountValue: discountValue,
        maxUses: maxUses,
        termsAndConditions: terms,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        isActive: _isActive,
        isValidationDate: _startDateController.text.isNotEmpty || _endDateController.text.isNotEmpty,
        startDate: _startDateController.text.trim().isEmpty ? null : _startDateController.text.trim(),
        endDate: _endDateController.text.trim().isEmpty ? null : _endDateController.text.trim(),
        applyOfferAfterOrders: applyAfter,
        minOrderAmount: minOrder,
        maxDiscountAmount: maxDiscount,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promo code created successfully')),
      );
      _codeController.clear();
      _discountValueController.clear();
      _minOrderAmountController.clear();
      _maxDiscountAmountController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _maxUsesController.clear();
      _termsAndConditionsController.clear();
      _descriptionController.clear();
      _applyOfferAfterOrdersController.clear();
      setState(() => _selectedImage = null);
      _loadPromoCodes();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.isEmpty ? 'Error creating promo code' : msg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Form
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
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AdminTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Create Promo Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: AdminTheme.uploadSectionDecoration(context),
                      child: _selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_selectedImage!, fit: BoxFit.cover),
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
                                Text('Tap to upload image', style: TextStyle(color: AdminTheme.fieldTextMuted(context))),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Code *'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDiscountType ?? 'percentage',
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Discount Type *'),
                    items: const [
                      DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDiscountType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _discountValueController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Discount Value *'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _minOrderAmountController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Min Order Amount *'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxDiscountAmountController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Max Discount Amount *'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: AdminTheme.inputDecoration(context, labelText: 'Valid From *'),
                          readOnly: true,
                          onTap: () => _pickDate(_startDateController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: AdminTheme.inputDecoration(context, labelText: 'Valid To *'),
                          readOnly: true,
                          onTap: () => _pickDate(_endDateController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxUsesController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Max Uses *'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _termsAndConditionsController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Terms & Conditions *'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Description (Optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: AdminTheme.inputDecoration(context, labelText: 'Start Date (Optional)'),
                          readOnly: true,
                          onTap: () => _pickDate(_startDateController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: AdminTheme.inputDecoration(context, labelText: 'End Date (Optional)'),
                          readOnly: true,
                          onTap: () => _pickDate(_endDateController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _applyOfferAfterOrdersController,
                    decoration: AdminTheme.inputDecoration(context, labelText: 'Apply Offer After Orders (Optional)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Is Active'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _isLoading ? null : _createPromoCode,
                    style: AdminTheme.primaryButtonStyle,
                    child: _isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Promo Code'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Search and List
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
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: AdminTheme.inputDecoration(
                            context,
                            labelText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _loadPromoCodes,
                        style: AdminTheme.primaryButtonStyle,
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _promoCodes.isEmpty
                          ? const Center(child: Text('No promo codes found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _promoCodes.length,
                              itemBuilder: (context, index) {
                                final raw = _promoCodes[index];
                                final promo = raw is Map
                                    ? Map<String, dynamic>.from(
                                        raw.map((k, v) => MapEntry(k.toString(), v)),
                                      )
                                    : <String, dynamic>{};
                                final code = promo['code']?.toString() ?? 'Unknown';
                                final discountValue = promo['discountValue']?.toString() ?? 'N/A';
                                final discountType = promo['discountType']?.toString() ?? '';
                                final promoId = (promo['_id'] ?? promo['id'])?.toString() ?? '';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(AdminTheme.radiusButton),
                                  ),
                                  child: ListTile(
                                    title: Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('Discount: $discountValue $discountType'),
                                    trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditDialog(promo),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Promo Code'),
                                              content: const Text('Are you sure you want to delete this promo code?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true && promoId.isNotEmpty) {
                                            try {
                                              await _adminService.deletePromoCode(promoCodeId: promoId);
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Promo code deleted successfully')),
                                                );
                                                _loadPromoCodes();
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(msg.isEmpty ? 'Error deleting promo code' : msg)),
                                                );
                                              }
                                            }
                                          }
                                        },
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
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderAmountController.dispose();
    _maxDiscountAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _maxUsesController.dispose();
    _termsAndConditionsController.dispose();
    _descriptionController.dispose();
    _applyOfferAfterOrdersController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

