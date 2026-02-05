class GuestItem {
  final int id;
  final String fullName;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String rsvpStatus;
  final String rsvpStatusLabel;
  final bool invitationSent;
  final int totalGuests;
  final String? mealPreference;
  final String? dietaryRestrictions;
  final String? notes;
  final bool hasResponded;
  final int guestCount;
  final int plusOneCount;
  final String invitationCode;

  GuestItem({
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.rsvpStatus,
    required this.rsvpStatusLabel,
    required this.invitationSent,
    required this.totalGuests,
    required this.guestCount,
    required this.plusOneCount,
    this.dietaryRestrictions,
    required this.hasResponded,
    this.mealPreference,
    this.notes,
    required this.invitationCode,
  });

  factory GuestItem.fromJson(Map<String, dynamic> json) {
    return GuestItem(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      rsvpStatus: json['rsvp_status'],
      rsvpStatusLabel: json['rsvp_status_label'],
      invitationSent: json['invitation_sent'] ?? false,
      totalGuests: json['total_guests'] ?? 0,
      guestCount: json['guest_count'] ?? 1,
      plusOneCount: json['plus_one_count'] ?? 0,
      mealPreference: json['meal_preference'],
      dietaryRestrictions: json['dietary_restrictions'],
      notes: json['notes'],
      hasResponded: json['has_responded'] ?? false,
      invitationCode: json['invitation_code'] ?? '',
    );
  }
}

class RSVPStatistics {
  final int totalInvited;
  final int attending;
  final int pending;
  final int declined;
  final int maybe;
  final double responseRate;
  final int totalGuestCount;
  final int totalPlusOne;
  final int totalExpectedAttendees;

  RSVPStatistics({
    required this.totalInvited,
    required this.attending,
    required this.pending,
    required this.declined,
    required this.maybe,
    required this.responseRate,
    required this.totalGuestCount,
    required this.totalPlusOne,
    required this.totalExpectedAttendees,
  });

  factory RSVPStatistics.fromJson(Map<String, dynamic> json) {
    return RSVPStatistics(
      totalInvited: json['total_invited'] ?? 0,
      attending: json['attending'] ?? 0,
      pending: json['pending'] ?? 0,
      declined: json['not_attending'] ?? 0,
      maybe: json['maybe'] ?? 0,
      responseRate: (json['response_rate'] ?? 0).toDouble(),
      totalGuestCount: int.tryParse(json['total_guest_count']?.toString() ?? '0') ?? 0,
      totalPlusOne: json['total_plus_one'] ?? 0,
      totalExpectedAttendees: json['total_expected_attendees'] ?? 0,
    );
  }
}