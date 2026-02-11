import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/service_model.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/cart_service.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:provider/provider.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/availability_service.dart';

class BookServiceTab extends StatefulWidget {
  final ServiceData service;
  const BookServiceTab({super.key, required this.service});

  @override
  State<BookServiceTab> createState() => _BookServiceTabState();
}

class _BookServiceTabState extends State<BookServiceTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _cartService = CartService();
  final AvailabilityService _availabilityService = AvailabilityService();

  @override
  bool get wantKeepAlive => true;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int capacity = 1;
  bool _isLoading = false;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController(
    text: "1",
  );
  int? _selectedAreaId;

  List<Slot> _availableSlots = [];
  bool _isCheckingAvailability = false;
  String? _availabilityError;

  @override
  void initState() {
    super.initState();
    if (widget.service.fixedCapacity) {
      capacity = widget.service.capacity ?? 1;
    }
    _capacityController.text = capacity.toString();
  }

  Future<void> _onDateChanged(DateTime date) async {
    setState(() {
      selectedDate = date;
      _isCheckingAvailability = true;
      _availabilityError = null;
      startTime = null;
      endTime = null;
    });

    try {
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final slots = await _availabilityService.getReservedSlots(
        widget.service.id,
        dateStr,
        "service",
      );

      setState(() {
        _availableSlots = slots;
        if (slots.isNotEmpty && slots.every((s) => !s.isAvailable)) {
          _availabilityError =
              "The whole day is busy, please choose another day";
        }
      });
    } catch (e) {
      setState(() => _availabilityError = "Could not load availability");
    } finally {
      setState(() => _isCheckingAvailability = false);
    }
  }

  bool _isHourAvailable(int hour) {
    if (_availableSlots.isEmpty) return true;
    final timeStr = "${hour.toString().padLeft(2, '0')}:00";
    return _availableSlots.any((s) => s.startTime == timeStr && s.isAvailable);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Not set";
    return "${time.hour.toString().padLeft(2, '0')}:00";
  }

  Widget _buildAreaDropdown() {
    final List<AvailableArea> areas = widget.service.availableAreas ?? [];

    if (areas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "No specific areas available for this service",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return CustomDropdownField<int>(
      label: "Select Area (Required)",
      value: _selectedAreaId,
      hintText: 'Choose an area',
      validator: (val) => val == null ? 'Please select an area' : null,
      items: areas.map((area) {
        return DropdownMenuItem<int>(value: area.id, child: Text(area.name));
      }).toList(),
      onChanged: (val) {
        setState(() => _selectedAreaId = val);
      },
    );
  }

  Future<void> _handleAddToCart() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      AppAlerts.showPopup(context, 'Please select a date', isError: true);
      return;
    }

    if (startTime == null || endTime == null) {
      AppAlerts.showPopup(
        context,
        'Please select start and end times',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dateStr =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      final int targetAreaId = _selectedAreaId ?? (widget.service.areaId ?? 0);
      if (!widget.service.fixedCapacity) {
        capacity = int.tryParse(_capacityController.text.trim()) ?? 1;
      }
      await _cartService.addToCart(
        bookableId: widget.service.id,
        eventDate: dateStr,
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        capacity: !widget.service.fixedCapacity ? capacity : null,
        areaId: targetAreaId,
        notes: notesController.text.trim(),
      );

      if (mounted) {
        context.read<CartProvider>().refreshCart();
        AppAlerts.showPopup(context, 'Added to cart successfully!');
      }
    } catch (e) {
      if (mounted) AppAlerts.showPopup(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildPickerTile(
                      icon: Icons.calendar_today,
                      text: selectedDate == null
                          ? 'Choose Date'
                          : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                        );
                        if (date != null) _onDateChanged(date);
                      },
                    ),

                    if (selectedDate == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "choose a date first",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    if (_availabilityError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _availabilityError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                    const Text(
                      'Choose Area',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    _buildAreaDropdown(),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeCol(
                            "Start Time",
                            startTime,
                            (t) => setState(() => startTime = t),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeCol(
                            "End Time",
                            endTime,
                            (t) => setState(() => endTime = t),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Capacity / Guests ${widget.service.fixedCapacity ? "(Fixed)" : "(Required)"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (widget.service.fixedCapacity)
                      Text(
                        '${widget.service.capacity} Persons (Fixed)',
                        style: const TextStyle(color: Colors.grey),
                      )
                    else
                      _capacityCounter(),

                    const SizedBox(height: 20),
                    const Text(
                      'Additional Notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Any special requests?',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
                onPressed: _isLoading ? null : _handleAddToCart,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCol(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay) onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        _buildPickerTile(
          icon: Icons.access_time,
          text: _formatTime(time),
          onTap: () async {
            if (selectedDate == null || _availabilityError != null) {
              AppAlerts.showPopup(
                context,
                "Please choose an available date first",
                isError: true,
              );
              return;
            }

            final t = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 12, minute: 0),
            );
            if (t != null) {
              if (!_isHourAvailable(t.hour)) {
                AppAlerts.showPopup(
                  context,
                  "This hour is already reserved",
                  isError: true,
                );
              } else {
                onPick(TimeOfDay(hour: t.hour, minute: 0));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _capacityCounter() {
    final bool isFixed = widget.service.fixedCapacity;

    void applyFromText() {
      final txt = _capacityController.text.trim();
      final n = int.tryParse(txt);

      if (n == null || n < 1) {
        setState(() => capacity = 1);
        _capacityController.text = "1";
        return;
      }

      setState(() => capacity = n);
    }

    void setCap(int newValue) {
      if (newValue < 1) newValue = 1;
      setState(() => capacity = newValue);
      _capacityController.text = newValue.toString();
    }

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: isFixed
              ? null
              : () {
                  applyFromText();
                  if (capacity > 1) {
                    setCap(capacity - 1);
                  }
                },
        ),

        SizedBox(
          width: 80,
          child: TextFormField(
            controller: _capacityController,
            enabled: !isFixed,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
            onChanged: (_) {},
            onFieldSubmitted: (_) => applyFromText(),
            onEditingComplete: () {
              applyFromText();
              FocusScope.of(context).unfocus();
            },
          ),
        ),

        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: isFixed
              ? null
              : () {
                  applyFromText();
                  setCap(capacity + 1);
                },
        ),
      ],
    );
  }
}
