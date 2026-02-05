import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/guest_model.dart';

class RSVPStatsHeader extends StatefulWidget {
  final RSVPStatistics stats;

  const RSVPStatsHeader({super.key, required this.stats});

  @override
  State<RSVPStatsHeader> createState() => _RSVPStatsHeaderState();
}

class _RSVPStatsHeaderState extends State<RSVPStatsHeader> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColor.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER ROW: Always Visible
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 18, color: AppColor.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Geusts Statistics",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.blueFont,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),

            // Toggle between views
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isExpanded ? _buildExpandedView() : _buildCompactView(),
            ),
          ],
        ),
      ),
    );
  }

  /// --- COMPACT VIEW (Single Line) ---
  Widget _buildCompactView() {
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _miniStat("Expected", widget.stats.totalExpectedAttendees.toString()),
          _miniStat("Attending", widget.stats.attending.toString(), color: Colors.green),
          _miniStat("Pending", widget.stats.pending.toString(), color: Colors.orange),
          _miniStat("Rate", "${widget.stats.responseRate.toInt()}%"),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text("$value ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  /// --- EXPANDED VIEW (Full Dashboard) ---
  Widget _buildExpandedView() {
    return Column(
      key: const ValueKey(2),
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            _buildProgressCircle(),
            const SizedBox(width: 20),
            _buildMainInfo(),
          ],
        ),
        const Divider(height: 32),
        _buildDetailedGrid(),
        const SizedBox(height: 16),
        _buildGuestBreakdown(),
      ],
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 65,
          width: 65,
          child: CircularProgressIndicator(
            value: widget.stats.responseRate / 100,
            strokeWidth: 6,
            backgroundColor: AppColor.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
          ),
        ),
        Text(
          "${widget.stats.responseRate.toInt()}%",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.primary),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Expected Attendees",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(
            "${widget.stats.totalExpectedAttendees}",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: AppColor.blueFont),
          ),
          Text("From ${widget.stats.totalInvited} invitations",
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailedGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSmallStat("Attending", widget.stats.attending.toString(), Colors.green),
        _buildSmallStat("Pending", widget.stats.pending.toString(), Colors.orange),
        _buildSmallStat("Maybe", widget.stats.maybe.toString(), Colors.blueAccent),
        _buildSmallStat("Declined", widget.stats.declined.toString(), Colors.redAccent),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildGuestBreakdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconStat(Icons.person, "Guests", widget.stats.totalGuestCount.toString()),
          _buildIconStat(Icons.group_add, "Plus Ones", widget.stats.totalPlusOne.toString()),
        ],
      ),
    );
  }

  Widget _buildIconStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text("$value $label",
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
      ],
    );
  }
}