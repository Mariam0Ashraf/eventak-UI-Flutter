import 'dart:io' show File; // [FOR MOBILE] To handle local files
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // [FOR TESTING] To check if on Laptop/Web
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // [FOR MOBILE] To save to device
import 'package:share_plus/share_plus.dart'; // [FOR MOBILE] To open share sheet
import 'dart:html' as html if (dart.library.io) 'dart:io'; // [CONDITIONAL IMPORT] Prevents mobile crash

// App specific imports
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import '../data/guest_model.dart';
import '../data/guest_service.dart';
import '../widgets/guest_list_tile.dart';
import '../widgets/rsvp_stats_header.dart';
import '../widgets/guest_action_toolbar.dart';
import '../widgets/guest_dialog.dart';
import '../widgets/empty_state_guests.dart';
import '../widgets/guest_constants.dart';
import '../widgets/invitation_sheet.dart';


class GuestManagementView extends StatefulWidget {
  final int eventId;
  const GuestManagementView({super.key, required this.eventId});

  @override
  State<GuestManagementView> createState() => _GuestManagementViewState();
}

class _GuestManagementViewState extends State<GuestManagementView> {
  final GuestService _service = GuestService();
  final ScrollController _scrollController = ScrollController();
  
  List<GuestItem> _guests = [];
  RSVPStatistics? _stats;
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  String? _searchQuery;
  String? _selectedRsvpStatus; 
  bool? _selectedInviteStatus;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _lastPage) {
      _loadMoreGuests();
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.fetchGuests(
          widget.eventId,
          page: 1,
          rsvpStatus: _selectedRsvpStatus,
          invitationSent: _selectedInviteStatus,
          search: _searchQuery,
        ),
        _service.fetchStatistics(widget.eventId), 
      ]);

      final guestData = results[0] as Map<String, dynamic>;
      final statsData = results[1] as RSVPStatistics;

      setState(() {
        _guests = guestData['guests'];
        _lastPage = guestData['last_page'];
        _stats = statsData; // Update the header stats 
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Refresh Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreGuests() async {
    setState(() => _isLoadingMore = true);
    try {
      final result = await _service.fetchGuests(
        widget.eventId,
        page: _currentPage + 1,
        rsvpStatus: _selectedRsvpStatus,
        invitationSent: _selectedInviteStatus,
        search: _searchQuery,
      );
      setState(() {
        _guests.addAll(result['guests']);
        _currentPage = result['current_page'];
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => GuestFormDialog(
      eventId: widget.eventId,
      onSuccess: _refreshData, 
    ),
    );
  }

  void _showEditGuestDialog(GuestItem guest) {
    showDialog(
      context: context,
      builder: (context) => GuestFormDialog(
        eventId: widget.eventId,
        guest: guest, // Passing the guest triggers "Edit Mode"
        onSuccess: _refreshData,
      ),
    );
  }

  void _showFilterMenu() {
    String? tempRsvp = _selectedRsvpStatus;
    bool? tempInvite = _selectedInviteStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row( //title
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Guests",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempRsvp = null;
                            tempInvite = null;
                          });
                        },
                        child: const Text("Reset"),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  /// RSVP STATUS
                  const Text("RSVP Status", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: GuestConstants.rsvpOptions.entries.map((entry) {
                      return _chip(
                        entry.value, // "Attending"
                        tempRsvp == entry.key, // compare against "attending"
                        () {
                          setModalState(() {
                            tempRsvp = tempRsvp == entry.key ? null : entry.key;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  /// INVITATION STATUS
                  const Text("Invitation", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip("Sent", tempInvite == true, () {
                        setModalState(() {
                          tempInvite = tempInvite == true ? null : true;
                        });
                      }),
                      _chip("Not Sent", tempInvite == false, () {
                        setModalState(() {
                          tempInvite = tempInvite == false ? null : false;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  /// APPLY BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRsvpStatus = tempRsvp;
                          _selectedInviteStatus = tempInvite;
                        });
                        Navigator.pop(context);
                        _refreshData();
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColor.primary.withOpacity(0.15),
      checkmarkColor: AppColor.primary,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Guests & RSVP', style: TextStyle(color: AppColor.blueFont)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_stats != null) RSVPStatsHeader(stats: _stats!),
          GuestActionToolbar(
            onAddManual: _showAddDialog,
            onDownloadTemplate: _handleDownloadTemplate,
            onImportFile: () => _handleBulkImportFile(),
            onSendAll: () => _handleSendAll(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // 1. The Search Bar
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _refreshData();
                    },
                    decoration: InputDecoration(
                      hintText: "Search guests...",
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 2. The Filter Button
                OutlinedButton(
                  onPressed: _showFilterMenu,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    padding: const EdgeInsets.all(10),
                  ),
                  child: const Icon(Icons.tune_rounded),
                )
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              :_guests.isEmpty 
                ? GuestEmptyState( // 2. Load complete, but no data
                    onAddManual: _showAddDialog,
                    onImport: _handleBulkImportFile,
                  )
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _guests.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _guests.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return GuestListTile(
                          guest: _guests[index],
                          onDelete: () async {
                            final ok = await _service.deleteGuest(widget.eventId, _guests[index].id);
                            if (ok) _refreshData();
                          },
                          onEdit: () => _showEditGuestDialog(_guests[index]),
                          onSendInvite: () => _showInvitationOptions(_guests[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendAll() async {
    // 1. Show the Confirmation Pop-up
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Bulk Invitations"),
        content: const Text(
          "This will send invitations to all uninvited guests using their available contact info (Email/SMS). Proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            child: const Text("Send Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    // 2. If user confirmed, trigger the service
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final result = await _service.sendAllMultiChannel(widget.eventId);
        AppAlerts.showPopup(context, "Success! \n Sent ${result['email_sent']} Emails and ${result['sms_sent']} SMS.");
        _refreshData(); 
      } catch (e) {
        debugPrint("Bulk Invite Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send bulk invitations.")),
        );
        setState(() => _isLoading = false);
      }
    }
  }


  void _showInvitationOptions(GuestItem guest) {
    showInvitationOptions(
      context,
      onEmail: () => _handleIndividualInvite(guest, isEmail: true),
      onSms: () => _handleIndividualInvite(guest, isEmail: false),
    );
  }

  Future<void> _handleIndividualInvite(GuestItem guest, {required bool isEmail}) async {
    setState(() => _isLoading = true);
    bool success = isEmail 
        ? await _service.sendEmailInvite(widget.eventId, guest.id)
        : await _service.sendSmsInvite(widget.eventId, guest.id);
    
    if (success) {
      _refreshData(); // Refresh to show "INVITED" status
      AppAlerts.showPopup(context, "Invitation sent via ${isEmail ? 'Email' : 'SMS'}!");

    } else {
      setState(() => _isLoading = false);
    }
  }

 // [FOR WEB & MOBILE] Handles the Template Download
  Future<void> _handleDownloadTemplate() async {
    setState(() => _isLoading = true);
    try {
      final Uint8List bytes = await _service.downloadGuestTemplate(widget.eventId);
      final String fileName = "guest_template.csv";

      if (kIsWeb) {
        // --- LAPTOP / WEB SPECIFIC ---
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        AppAlerts.showPopup(context, "Template downloaded to your laptop Downloads!");
      } else {
        // --- MOBILE SPECIFIC ---
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);

        // Opens the Mobile Share menu so user can save/send the file
        await Share.shareXFiles([XFile(file.path)], subject: 'Guest Template');
      }
    } catch (e) {
      AppAlerts.showPopup(context, "Download failed", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // [FOR WEB & MOBILE] Universal Import Function
  Future<void> _handleBulkImportFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true, // Crucial for getting bytes on Laptop/Web
    );

    if (result != null) {
      setState(() => _isLoading = true);
      final file = result.files.single;

      bool success = await _service.uploadGuestFile(
        eventId: widget.eventId,
        fileBytes: file.bytes!, // Works on laptop and phone
        fileName: file.name,
      );

      if (success) {
        _refreshData();
        AppAlerts.showPopup(context, "Import successful!");
      } else {
        AppAlerts.showPopup(context, "Import failed", isError: true);
      }
      setState(() => _isLoading = false);
    }
  }

}