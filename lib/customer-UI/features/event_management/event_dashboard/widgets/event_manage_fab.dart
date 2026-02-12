import 'package:eventak/customer-UI/features/event_management/event_dashboard/view/event_details_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/budget/view/budget_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/gallery/view/gallery_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/guests&rvsp/view/guest_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/timeline/view/timeline_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/todo/view/todo_view.dart';
import 'package:eventak/customer-UI/features/event_management/tools/website/view/event_website_view.dart';
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
                const SizedBox(height: 10),
                _buildOption(Icons.collections_outlined, "Gallery", 4),
                const SizedBox(height: 10),
                _buildOption(Icons.web, "Website", 5), 
                const SizedBox(height: 10),
                _buildOption(Icons.people, "Invitations", 6)
              ],
            ),
          ),

        // Animated Button: Transitions from Rectangle to Circle
        GestureDetector(
          onTap: _toggleMenu,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isMenuOpen ? 45 : 120, // Expands for text, shrinks for 'X'
            height: 45,
            decoration: BoxDecoration(
              color: AppColor.primary,
              // Changes from rounded rectangle to perfect circle
              borderRadius: BorderRadius.circular(isMenuOpen ? 25 : 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isMenuOpen
                    ? const Icon(
                        Icons.close,
                        key: ValueKey('close'),
                        color: Colors.white,
                        size: 20,
                      )
                    : Row(
                        key: const ValueKey('tools'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.grid_view_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Event Tools",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
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
      case 4:
        nextScreen = EventGalleryView(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
        );
        break;
      case 5:
        nextScreen = EventWebsiteView(
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
        );
        break;
      case 6:
        nextScreen = GuestManagementView(eventId: widget.eventId, eventTitle: widget.eventTitle);
        break;
      default:
        return;
    }

    if (widget.activeIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }
}
