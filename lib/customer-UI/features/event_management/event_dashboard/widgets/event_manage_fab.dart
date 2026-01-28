import 'package:eventak/customer-UI/features/event_management/event_dashboard/view/event_details_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/budget/view/budget_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/todo/view/todo_view.dart';
import 'package:eventak/customer-UI/features/tools/timeline/view/timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class EventManagementFab extends StatefulWidget {
  final int eventId;
  final int activeIndex;
  final String eventTitle;

  const EventManagementFab({
    super.key,
    required this.eventId,
    required this.activeIndex,
    required this.eventTitle,
  });

  @override
  State<EventManagementFab> createState() => _EventManagementFabState();
}

class _EventManagementFabState extends State<EventManagementFab> {
  bool isMenuOpen = false;

  void _toggleMenu() {
    setState(() => isMenuOpen = !isMenuOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (isMenuOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 55),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOption(Icons.info_outline, "Details", 0),
                const SizedBox(height: 10),
                _buildOption(Icons.check_box_outlined, "Todo List", 1),
                const SizedBox(height: 10),
                _buildOption(Icons.timeline, "Timeline", 2),
                const SizedBox(height: 10),
                _buildOption(Icons.account_balance_wallet_outlined, "Budget", 3),
              ],
            ),
          ),

        SizedBox(
          width: 45,
          height: 45,
          child: FloatingActionButton(
            backgroundColor: AppColor.primary,
            elevation: 4,
            onPressed: _toggleMenu,
            shape: const CircleBorder(),
            child: Icon(
              isMenuOpen ? Icons.close : Icons.grid_view_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(IconData icon, String label, int index) {
    final bool isActive = widget.activeIndex == index;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColor.primary : AppColor.blueFont,
            ),
          ),
        ),

        // Small FAB
        SizedBox(
          width: 35,
          height: 35,
          child: FloatingActionButton(
            heroTag: "fab_${widget.eventId}_$index",
            backgroundColor: isActive ? AppColor.primary : Colors.white,
            elevation: 2,
            shape: const CircleBorder(),
            onPressed: () {
              _toggleMenu();
              if (isActive) return;
              _handleNavigation(index, context);
            },
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColor.primary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _handleNavigation(int index, BuildContext context) {
    late final Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = EventDetailsView(eventId: widget.eventId);
        break;
      case 1:
        nextScreen = TodoListView(eventId: widget.eventId);
        break;
      case 2:
        nextScreen = TimelineView(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
        );
        break;
      case 3:
        nextScreen = BudgetView(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
        );
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
