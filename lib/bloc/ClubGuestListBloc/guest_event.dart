abstract class GuestEvent {}

class LoadGuests extends GuestEvent {
  final String eventId;

  LoadGuests({required this.eventId});
}

class SearchGuests extends GuestEvent {
  final String searchText;

  SearchGuests({required this.searchText});
}

// New event to update a guest status
class UpdateGuestStatus extends GuestEvent {
  final String eventId;
  final String guestId;
  final String status;

  UpdateGuestStatus({required this.eventId, required this.guestId, required this.status});
}



