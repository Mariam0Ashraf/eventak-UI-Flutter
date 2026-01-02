// lib/service-provider-UI/shared/widgets/home_header.dart

import 'package:flutter/material.dart';

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
  //String? _selectedService;

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
}