import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/damage_report.dart';
import '../services/damage_report_repository.dart';
import '../theme/heritage_colors.dart';

class ReportAdminScreen extends StatefulWidget {
  const ReportAdminScreen({super.key});

  @override
  State<ReportAdminScreen> createState() => _ReportAdminScreenState();
}

class _ReportAdminScreenState extends State<ReportAdminScreen> {
  String _filter = 'all';
  bool _loading = false;
  List<DamageReport> _reports = const [
    DamageReport(id: '1', damageType: 'Structural Cracks', location: 'Galle Fort, Southern Wall', details: 'Report details awaiting review.', status: 'pending', createdAt: DateTime(2026)),
    DamageReport(id: '2', damageType: 'Vandalism', location: 'Sigiriya Rock Fortress', details: 'Report details awaiting review.', status: 'in_review', createdAt: DateTime(2026)),
    DamageReport(id: '3', damageType: 'Water Damage', location: 'Dambulla Cave Temple', details: 'Report details awaiting review.', status: 'resolved', createdAt: DateTime(2026)),
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _loading = true);
    try {
      final reports = await DamageReportRepository(Supabase.instance.client).list();
      if (mounted && reports.isNotEmpty) setState(() => _reports = reports);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(DamageReport report, String status) async {
    if (!AppConfig.hasSupabase) {
      setState(() => _reports = _reports.map((item) => item.id == report.id ? DamageReport(id: item.id, location: item.location, damageType: item.damageType, details: item.details, status: status, createdAt: item.createdAt) : item).toList());
      return;
    }
    await DamageReportRepository(Supabase.instance.client).updateStatus(report.id, status);
    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final reports = _reports.where((report) => _filter == 'all' || report.status == _filter).toList();
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')), const Text('Damage Reports', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold)), _round(Icons.notifications_none, () {})]), const SizedBox(height: 24), Row(children: [_stat('${_reports.length}', 'TOTAL', HeritageColors.cream), _stat('${_count('pending')}', 'PENDING', HeritageColors.orange), _stat('${_count('in_review')}', 'IN REVIEW', const Color(0xFF52B788)), _stat('${_count('resolved')}', 'RESOLVED', const Color(0xFFA8DADC))]), if (_loading) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator(color: HeritageColors.orange, backgroundColor: Color(0x1AFFFFFF))), const SizedBox(height: 24), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['all', 'pending', 'in_review', 'resolved', 'rejected'].map((status) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(status.toUpperCase().replaceAll('_', ' ')), selected: _filter == status, selectedColor: HeritageColors.orange, backgroundColor: Colors.white.withOpacity(0.05), labelStyle: TextStyle(color: _filter == status ? HeritageColors.background : const Color(0x99FFFFFF), fontSize: 10, fontWeight: FontWeight.bold), onSelected: (_) => setState(() => _filter = status))).toList())), const SizedBox(height: 20), ...reports.map(_reportCard)])));
  }

  int _count(String status) => _reports.where((report) => report.status == status).length;
  Widget _reportCard(DamageReport report) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(report.damageType, style: const TextStyle(color: HeritageColors.orange, fontWeight: FontWeight.bold))), _badge(report.status)]), const SizedBox(height: 8), Text(report.location, style: const TextStyle(color: HeritageColors.cream, fontSize: 14)), const SizedBox(height: 8), Text(report.details.isEmpty ? 'Report details awaiting review.' : report.details, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12)), const SizedBox(height: 12), Row(children: [TextButton(onPressed: () => _updateStatus(report, 'in_review'), child: const Text('Review', style: TextStyle(color: HeritageColors.orange))), TextButton(onPressed: () => _updateStatus(report, 'resolved'), child: const Text('Resolve', style: TextStyle(color: Color(0xFF52B788))),), TextButton(onPressed: () => _updateStatus(report, 'rejected'), child: const Text('Reject', style: TextStyle(color: Color(0xFFE76F51))))])]));
  Widget _stat(String value, String label, Color color) => Expanded(child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), decoration: BoxDecoration(color: color.withOpacity(0.06), border: Border.all(color: color.withOpacity(0.18)), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)), Text(label, style: TextStyle(color: color.withOpacity(0.60), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1))])));
  Widget _badge(String status) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: HeritageColors.orange.withOpacity(0.10), border: Border.all(color: HeritageColors.orange.withOpacity(0.30)), borderRadius: BorderRadius.circular(20)), child: Text(status.replaceAll('_', ' '), style: const TextStyle(color: HeritageColors.orange, fontSize: 10, fontWeight: FontWeight.bold)));
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)));
}
