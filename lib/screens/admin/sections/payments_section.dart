import 'package:flutter/material.dart';
import '../../../services/admin_service.dart';
import '../../../services/trainer_service.dart';
import '../../../widgets/admin/admin_theme.dart';
import '../../../widgets/admin/admin_section_card.dart';
import '../../../widgets/admin/admin_summary_cards.dart';
import '../../../widgets/admin/admin_filter_bar.dart';
import '../../../widgets/admin/admin_simple_table.dart';
import '../../../widgets/admin/admin_empty_state.dart';

class PaymentsSection extends StatefulWidget {
  const PaymentsSection({super.key});

  @override
  State<PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends State<PaymentsSection> {
  final _adminService = AdminService();
  final _trainerService = TrainerService();
  String _searchQuery = '';
  String _statusFilter = 'All';
  bool _adminView = true;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _allPayments = [];
  bool _loading = false;
  bool _dashboardLoading = false;
  String _totalRevenue = '—';
  String _completed = '—';
  String _pending = '—';
  String _failed = '—';
  int _selectedYear = DateTime.now().year;
  List<Map<String, dynamic>> _monthWiseData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadPayments();
    _loadMonthWiseData();
  }

  /// GET /admin/get-dashboard-details — summary for Total Revenue, Completed, Pending, Failed
  Future<void> _loadDashboard() async {
    if (!_adminView) return;
    if (!mounted) return;
    setState(() => _dashboardLoading = true);
    try {
      final data = await _adminService.getDashboardDetails();
      if (!mounted) return;
      setState(() {
        _dashboardLoading = false;
        if (data != null) {
          _totalRevenue = _formatNumber(data['totalRevenue'] ?? data['total_revenue'] ?? data['revenue']) ?? '—';
          _completed = _formatNumber(data['completed'] ?? data['completedCount']) ?? '—';
          _pending = _formatNumber(data['pending'] ?? data['pendingCount']) ?? '—';
          _failed = _formatNumber(data['failed'] ?? data['failedCount']) ?? '—';
        }
      });
    } catch (_) {
      if (mounted) setState(() => _dashboardLoading = false);
    }
  }

  String? _formatNumber(dynamic v) {
    if (v == null) return null;
    if (v is num) return v is int ? v.toString() : (v as double).toStringAsFixed(2);
    if (v is String) return v;
    return v.toString();
  }

  /// GET /admin/get-all-orders (Admin) or GET /trainer/get-all-orders (Trainer)
  Future<void> _loadPayments() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      List<dynamic> raw = [];
      if (_adminView) {
        final result = await _adminService.getAllOrders();
        final d = result as dynamic;
        if (d is List) {
          raw = List<dynamic>.from(d);
        } else if (d is Map<String, dynamic>) {
          final list = d['orders'] ?? d['data'] ?? d['order'];
          raw = list is List ? List<dynamic>.from(list) : [];
        }
      } else {
        raw = await _trainerService.getAllOrders();
      }
      final normalized = raw.map((e) => _normalizeOrder(e)).toList();
      if (!mounted) return;
      setState(() {
        _allPayments = normalized;
        _payments = _applyFilters(normalized);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allPayments = [];
        _payments = [];
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payments: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _normalizeOrder(dynamic e) {
    final m = e is Map ? Map<String, dynamic>.from(e as Map) : <String, dynamic>{};
    Object? createdBy = m['created_by'] ?? m['createdBy'];
    String customer = '';
    if (createdBy is Map) {
      customer = (createdBy['firstName'] ?? createdBy['first_name'] ?? '').toString() +
          ' ' + (createdBy['lastName'] ?? createdBy['last_name'] ?? '').toString();
      customer = customer.trim().isEmpty ? (createdBy['email'] ?? '').toString() : customer;
    } else if (createdBy != null) customer = createdBy.toString();
    final amount = m['total_delivery_price'] ?? m['totalDeliveryPrice'] ?? m['amount'] ?? '';
    final date = m['order_date'] ?? m['orderDate'] ?? m['createdAt'] ?? m['created_at'] ?? '';
    String status = (m['status'] ?? m['bookingStatus'] ?? m['paymentStatus'] ?? '').toString();
    if (status.isEmpty) status = (m['pay_type'] ?? m['payType'] ?? 'Pending').toString();
    return {
      ...m,
      'id': m['_id'] ?? m['id'] ?? m['orderid'] ?? m['orderId'],
      'date': date is String ? date : date.toString(),
      'customer': customer,
      'amount': amount is num ? amount.toString() : amount.toString(),
      'status': status,
    };
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    var out = list;
    if (_statusFilter != 'All') {
      out = out.where((p) => (p['status'] ?? '').toString().toLowerCase() == _statusFilter.toLowerCase()).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      out = out.where((p) =>
          (p['customer'] ?? '').toString().toLowerCase().contains(q) ||
          (p['amount'] ?? '').toString().toLowerCase().contains(q) ||
          (p['date'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
    return out;
  }

  /// GET /admin/get-month-wise-data?year=2024
  Future<void> _loadMonthWiseData() async {
    if (!_adminView) return;
    try {
      final result = await _adminService.getMonthWiseData(year: _selectedYear);
      if (!mounted) return;
      final data = result as dynamic;
      List<Map<String, dynamic>> out = [];
      if (data is List) {
        out = data.map((e) => e is Map ? Map<String, dynamic>.from(e as Map) : <String, dynamic>{}).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['months'] ?? data['monthWise'] ?? [];
        if (list is List) {
          out = list.map((e) => e is Map ? Map<String, dynamic>.from(e as Map) : <String, dynamic>{}).toList();
        }
      }
      if (mounted) setState(() => _monthWiseData = out);
    } catch (_) {
      if (mounted) setState(() => _monthWiseData = []);
    }
  }

  void _showOrderDetail(Map<String, dynamic> p) {
    final id = (p['id'] ?? p['_id'] ?? '').toString();
    if (!_adminView && id.isNotEmpty) {
      _loadTrainerOrderDetail(id);
      return;
    }
    _showOrderDetailDialog(p);
  }

  /// GET /trainer/get-all-order-by-id/:id — full order for trainer view
  Future<void> _loadTrainerOrderDetail(String orderId) async {
    try {
      final order = await _trainerService.getOrderById(orderId);
      if (!mounted) return;
      if (order != null) {
        final normalized = _normalizeOrder(order);
        _showOrderDetailDialog(normalized);
      } else {
        _showOrderDetailDialog({'date': '—', 'customer': '—', 'amount': '—', 'status': '—'});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load order: $e')));
      }
    }
  }

  void _showOrderDetailDialog(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Date', p['date']?.toString() ?? '—'),
              _detailRow('Customer', p['customer']?.toString() ?? '—'),
              _detailRow('Amount', p['amount']?.toString() ?? '—'),
              _detailRow('Status', p['status']?.toString() ?? '—'),
              if (p['pay_type'] != null) _detailRow('Pay type', p['pay_type']?.toString() ?? '—'),
              if (p['orderid'] != null) _detailRow('Order ID', p['orderid']?.toString() ?? '—'),
              if (p['invoice'] != null) _detailRow('Invoice', p['invoice']?.toString() ?? '—'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
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
            TextSpan(text: value),
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
          if (_adminView) ...[
            AdminSummaryCards(
              children: [
                AdminSummaryCard(
                  title: 'Total Revenue',
                  value: _dashboardLoading ? '…' : _totalRevenue,
                  subtitle: '% from last month',
                  icon: Icons.trending_up,
                  color: AdminTheme.primary,
                ),
                AdminSummaryCard(
                  title: 'Completed',
                  value: _dashboardLoading ? '…' : _completed,
                  icon: Icons.check_circle,
                  color: AdminTheme.success,
                ),
                AdminSummaryCard(
                  title: 'Pending',
                  value: _dashboardLoading ? '…' : _pending,
                  icon: Icons.schedule,
                  color: AdminTheme.warning,
                ),
                AdminSummaryCard(
                  title: 'Failed',
                  value: _dashboardLoading ? '…' : _failed,
                  icon: Icons.cancel,
                  color: AdminTheme.error,
                ),
              ],
            ),
            if (_monthWiseData.isNotEmpty) ...[
              const SizedBox(height: 16),
              AdminSectionCard(
                title: 'Revenue by month',
                child: Row(
                  children: [
                    DropdownButton<int>(
                      value: _selectedYear,
                      items: List.generate(5, (i) => DateTime.now().year - i).map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                      onChanged: (y) {
                        if (y != null) {
                          setState(() => _selectedYear = y);
                          _loadMonthWiseData();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _monthWiseData.map((m) {
                          final month = m['month'] ?? m['monthName'] ?? m['_id'] ?? '';
                          final value = m['total'] ?? m['revenue'] ?? m['amount'] ?? m['count'] ?? '—';
                          return Chip(label: Text('$month: $value'));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
          AdminFilterBar(
            filters: [
              DropdownButton<String>(
                value: _statusFilter,
                items: ['All', 'Completed', 'Pending', 'Failed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() {
                  _statusFilter = v ?? 'All';
                  _payments = _applyFilters(_allPayments);
                }),
              ),
            ],
            searchField: TextField(
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _payments = _applyFilters(_allPayments);
              }),
              decoration: AdminTheme.inputDecoration(context, hintText: 'Search payments…', prefixIcon: const Icon(Icons.search), isDense: true),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('Export Excel'),
                    style: AdminTheme.primaryButtonStyle,
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    label: const Text('Export PDF'),
                  ),
                ],
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Admin'), icon: Icon(Icons.admin_panel_settings)),
                  ButtonSegment(value: false, label: Text('Trainer'), icon: Icon(Icons.person)),
                ],
                selected: {_adminView},
                onSelectionChanged: (s) {
                  setState(() => _adminView = s.first);
                  _loadDashboard();
                  _loadPayments();
                  _loadMonthWiseData();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminSectionCard(
            title: _adminView ? 'Payments' : 'Trainer orders',
            child: _payments.isEmpty && !_loading
                ? AdminEmptyState(
                    icon: Icons.payment,
                    message: 'No payments to show. Connect payments API to load data.',
                  )
                : AdminSimpleTable(
                    columnLabels: const ['S.No', 'Date', 'Customer', 'Amount', 'Status', 'Actions'],
                    rows: _payments.asMap().entries.map((e) {
                      final i = e.key + 1;
                      final p = e.value;
                      return [
                        Text('$i'),
                        Text((p['date'] ?? '').toString()),
                        Text((p['customer'] ?? '').toString()),
                        Text((p['amount'] ?? '').toString()),
                        _statusChip((p['status'] ?? 'Pending').toString()),
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          onPressed: () => _showOrderDetail(p),
                        ),
                      ];
                    }).toList(),
                    isLoading: _loading,
                    totalItems: _payments.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color c = AdminTheme.warning;
    if (status.toLowerCase() == 'completed') c = AdminTheme.success;
    if (status.toLowerCase() == 'failed') c = AdminTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c)),
    );
  }
}
