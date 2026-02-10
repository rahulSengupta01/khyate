import 'package:flutter/material.dart';
import '../../../services/user_management_service.dart';
import '../../../widgets/admin/admin_theme.dart';
import '../../../widgets/admin/admin_section_card.dart';
import '../../../widgets/admin/admin_filter_bar.dart';
import '../../../widgets/admin/admin_simple_table.dart';
import '../../../widgets/admin/admin_empty_state.dart';

class CustomersSection extends StatefulWidget {
  const CustomersSection({super.key});

  @override
  State<CustomersSection> createState() => _CustomersSectionState();
}

class _CustomersSectionState extends State<CustomersSection> {
  final _userService = UserManagementService();
  String _ageGroupFilter = 'All Age Groups';
  String _genderFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _allCustomers = [];
  bool _loading = false;
  int _page = 1;
  static const _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// GET /user/get-customers-filtered with ageGroup and gender.
  Future<void> _loadCustomers() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      String? ageGroup;
      if (_ageGroupFilter != 'All Age Groups' && _ageGroupFilter.isNotEmpty) {
        switch (_ageGroupFilter) {
          case 'Under 18': ageGroup = 'under18'; break;
          case '18-25': ageGroup = '18to25'; break;
          case '26-35': ageGroup = '26to35'; break;
          case '36-45': ageGroup = '36to45'; break;
          case '46+': ageGroup = '46plus'; break;
          default: ageGroup = _ageGroupFilter.replaceAll('-', 'to').replaceAll(' ', '').toLowerCase();
        }
      }
      String? gender;
      if (_genderFilter != 'All' && _genderFilter.isNotEmpty) gender = _genderFilter;

      final list = await _userService.getCustomersFiltered(
        ageGroup: ageGroup,
        gender: gender,
      );
      final normalized = _normalizeCustomerList(list);
      if (!mounted) return;
      setState(() {
        _allCustomers = normalized;
        _customers = _applySearch(normalized, _searchQuery);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allCustomers = [];
        _customers = [];
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customers: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _normalizeCustomerList(List<dynamic> list) {
    return list.map<Map<String, dynamic>>((e) {
      final m = e is Map ? Map<String, dynamic>.from(e as Map) : <String, dynamic>{};
      final first = m['firstName'] ?? m['first_name'] ?? '';
      final last = m['lastName'] ?? m['last_name'] ?? '';
      final name = '$first $last'.trim().isEmpty ? (m['name'] ?? '') : '$first $last'.trim();
      Object? country = m['country'];
      Object? city = m['city'];
      String location = '';
      if (city is Map && city['name'] != null) location = city['name'].toString();
      else if (city is Map && city['cityName'] != null) location = city['cityName'].toString();
      else if (country is Map && country['name'] != null) location = country['name'].toString();
      else if (city != null) location = city.toString();
      else if (country != null) location = country.toString();
      final isActive = m['isActive'] ?? m['is_active'] ?? true;
      return {
        ...m,
        'id': m['_id'] ?? m['id'],
        'name': name,
        'email': m['email'] ?? '',
        'age': m['age']?.toString() ?? '',
        'gender': m['gender'] ?? '',
        'location': location,
        'address': m['address'] ?? '',
        'contact': m['phoneNumber'] ?? m['phone_number'] ?? '',
        'birthday': m['dateOfBirth'] ?? m['date_of_birth'] ?? m['birthday'] ?? '',
        'status': isActive == true ? 'Active' : 'Inactive',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> list, String q) {
    if (q.trim().isEmpty) return list;
    final lower = q.trim().toLowerCase();
    return list.where((c) {
      return (c['name'] ?? '').toString().toLowerCase().contains(lower) ||
          (c['email'] ?? '').toString().toLowerCase().contains(lower) ||
          (c['contact'] ?? '').toString().contains(q.trim());
    }).toList();
  }

  /// GET /user/get-userby-id/:id — show single customer details
  Future<void> _showCustomerDetail(String id) async {
    try {
      final raw = await _userService.getUserById(id);
      if (!mounted || raw == null) return;
      // Support nested user (e.g. API returns { user: { ... } }) and both camelCase/snake_case
      final user = (raw['user'] ?? raw['data'] ?? raw) is Map
          ? Map<String, dynamic>.from((raw['user'] ?? raw['data'] ?? raw) as Map)
          : raw;
      final name = '${user['firstName'] ?? user['first_name'] ?? ''} ${user['lastName'] ?? user['last_name'] ?? ''}'.trim();
      final displayName = name.isEmpty ? (user['name']?.toString() ?? '') : name;
      final email = user['email']?.toString() ?? '';
      final phone = user['phoneNumber'] ?? user['phone_number']?.toString() ?? '';
      final age = user['age']?.toString() ?? '';
      final gender = user['gender']?.toString() ?? '';
      final address = user['address']?.toString() ?? '';
      final isActive = user['isActive'] ?? user['is_active'];
      final status = isActive == true ? 'Active' : 'Inactive';
      final birthday = user['dateOfBirth'] ?? user['date_of_birth'] ?? user['birthday']?.toString() ?? '';
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Customer details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Name', displayName),
                _detailRow('Email', email),
                _detailRow('Phone', phone),
                _detailRow('Age', age),
                _detailRow('Gender', gender),
                _detailRow('Address', address),
                if (birthday.isNotEmpty) _detailRow('Birthday', birthday),
                _detailRow('Status', status),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customer: $e')),
        );
      }
    }
  }

  Widget _detailRow(String label, String value) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: color, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value.isEmpty ? '—' : value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFilterBar(
            onClearFilters: () {
              setState(() {
                _ageGroupFilter = 'All Age Groups';
                _genderFilter = 'All';
                _searchController.clear();
                _searchQuery = '';
              });
              _loadCustomers();
            },
            filters: [
              DropdownButton<String>(
                value: _ageGroupFilter,
                items: ['All Age Groups', 'Under 18', '18-25', '26-35', '36-45', '46+'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() {
                  _ageGroupFilter = v ?? 'All Age Groups';
                  _loadCustomers();
                }),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _genderFilter,
                items: ['All', 'Male', 'Female', 'Others'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() {
                  _genderFilter = v ?? 'All';
                  _loadCustomers();
                }),
              ),
            ],
            searchField: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _customers = _applySearch(_allCustomers, v);
              }),
              decoration: AdminTheme.inputDecoration(
                context,
                hintText: 'Search Customers…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: 'Customers',
            child: _customers.isEmpty && !_loading
                ? AdminEmptyState(
                    icon: Icons.people_outline,
                    message: 'No customers to show. Connect a customers list API to load data.',
                  )
                : AdminSimpleTable(
                    columnLabels: const [
                      'S.No', 'Name', 'Email', 'Age', 'Gender', 'Location', 'Address', 'Contact No', 'Birthday', 'Status', 'View',
                    ],
                    rows: _customers.asMap().entries.map((e) {
                      final i = e.key + 1;
                      final c = e.value;
                      return [
                        Text('$i'),
                        Text((c['name'] ?? '').toString()),
                        Text((c['email'] ?? '').toString()),
                        Text((c['age'] ?? '').toString()),
                        Text((c['gender'] ?? '').toString()),
                        Text((c['location'] ?? '').toString()),
                        Text((c['address'] ?? '').toString()),
                        Text((c['contact'] ?? '').toString()),
                        Text((c['birthday'] ?? '').toString()),
                        _statusChip((c['status'] ?? 'Active').toString()),
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          onPressed: () {
                            final id = (c['id'] ?? c['_id'] ?? '').toString();
                            if (id.isNotEmpty) _showCustomerDetail(id);
                          },
                          tooltip: 'View details',
                        ),
                      ];
                    }).toList(),
                    isLoading: _loading,
                    totalItems: _customers.length,
                    totalPages: 1,
                    currentPage: 1,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AdminTheme.success.withOpacity(0.15) : AdminTheme.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AdminTheme.success : AdminTheme.error,
        ),
      ),
    );
  }
}
