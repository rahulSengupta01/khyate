import 'package:flutter/material.dart';
import 'package:Outbox/screens/admin/admin_shell.dart';
import 'package:Outbox/screens/admin/trainer_manager.dart';
import 'package:Outbox/screens/admin/promo_code_manager.dart';
import 'package:Outbox/screens/admin/sections/customers_section.dart';
import 'package:Outbox/screens/admin/sections/memberships_section.dart';
import 'package:Outbox/screens/admin/sections/ratings_section.dart';
import 'package:Outbox/screens/admin/sections/masters_section.dart';

/// Admin Dashboard: modern shell (sidebar + top bar) with 6 sections.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminSection _currentSection = AdminSection.customers;

  String _sectionTitle() {
    switch (_currentSection) {
      case AdminSection.customers:
        return 'Customers';
      case AdminSection.trainers:
        return 'Trainers';
      case AdminSection.memberships:
        return 'Memberships';
      case AdminSection.promoCodes:
        return 'Promo Codes';
      case AdminSection.ratings:
        return 'Ratings';
      case AdminSection.masters:
        return 'Masters';
    }
  }

  Widget _sectionContent() {
    switch (_currentSection) {
      case AdminSection.customers:
        return const CustomersSection();
      case AdminSection.trainers:
        return TrainerManager();
      case AdminSection.memberships:
        return const MembershipsSection();
      case AdminSection.promoCodes:
        return PromoCodeManager();
      case AdminSection.ratings:
        return const RatingsSection();
      case AdminSection.masters:
        return const MastersSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentSection: _currentSection,
      sectionTitle: _sectionTitle(),
      onSectionChanged: (s) => setState(() => _currentSection = s),
      child: _sectionContent(),
    );
  }
}
