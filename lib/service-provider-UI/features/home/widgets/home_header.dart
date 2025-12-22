// lib/service-provider-UI/shared/widgets/home_header.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class HomeHeader extends StatefulWidget {
 // final List<String> services;
  final String providerName;

  const HomeHeader({
    super.key,
    //required this.services,
    required this.providerName,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    //_selectedService = widget.services.isNotEmpty ? widget.services.first : null;
  }

  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage('assets/App_photos/img.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back,',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              widget.providerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            //_buildServiceDropdown(),
          ],
        ),
      ],
    );
  }

  /*Widget _buildServiceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedService,
          icon: Icon(Icons.arrow_drop_down, color: AppColor.blueFont),
          style: const TextStyle(
              fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
          dropdownColor: Colors.white,
          items: widget.services.map((String service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() => _selectedService = newValue);
            debugPrint('Service selected: $newValue');
          },
        ),
      ),
    );
  }
  @override
void didUpdateWidget(covariant HomeHeader oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.services != widget.services &&
      widget.services.isNotEmpty &&
      _selectedService == null) {
    setState(() {
      _selectedService = widget.services.first;
    });
  }
}
*/}