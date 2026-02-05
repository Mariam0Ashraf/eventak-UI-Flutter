import 'package:flutter/material.dart';

void showInvitationOptions(BuildContext context, {
  required VoidCallback onEmail,
  required VoidCallback onSms,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Send Invitation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined, color: Colors.blue),
          title: const Text("Send via Email"),
          onTap: () { Navigator.pop(context); onEmail(); },
        ),
        ListTile(
          leading: const Icon(Icons.sms_outlined, color: Colors.green),
          title: const Text("Send via SMS"),
          onTap: () { Navigator.pop(context); onSms(); },
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}