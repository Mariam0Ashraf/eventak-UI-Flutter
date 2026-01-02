import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class BookServiceTab extends StatefulWidget {
  const BookServiceTab({super.key});

  @override
  State<BookServiceTab> createState() => _BookServiceTabState();
}

class _BookServiceTabState extends State<BookServiceTab> {
  DateTime? selectedDate;
  int selectedHours = 1;
  final TextEditingController notesController = TextEditingController();
  int hours = 1;
  static const int maxHours = 12; ///for the counter of houtrs 

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Widget _hoursCounter() {
  return Row(
    children: [
      /// MINUS
      _counterButton(
        icon: Icons.remove,
        onTap: hours > 1
            ? () => setState(() => hours--)
            : null,
      ),

      
      Container(
        width: 48,
        alignment: Alignment.center,
        child: Text(
          '$hours',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// plus
      _counterButton(
        icon: Icons.add,
        onTap: hours < maxHours
            ? () => setState(() => hours++)
            : null,
      ),

      const SizedBox(width: 8),

      /// hours word
      const Text(
        'hours',
        style: TextStyle(fontSize: 16),
      ),
    ],
  );
}


Widget _counterButton({
  required IconData icon,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
        color: onTap == null ? Colors.grey.shade200 : Colors.white,
      ),
      child: Icon(
        icon,
        size: 18,
        color: onTap == null ? Colors.grey : Colors.black,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Date Picker
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate == null
                                ? 'Choose a date'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Hours
                  Text(
                    'Number of Hours',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _hoursCounter(),

                  const SizedBox(height: 20),

                  
                  Text(
                    'Additional Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Any special comments',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              onPressed: () {
                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart (UI only)'),
                  ),
                );*/
              },
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
