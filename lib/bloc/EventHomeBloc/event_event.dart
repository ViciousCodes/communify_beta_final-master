abstract class EventEvent {}

class LoadEvents extends EventEvent {}

class SearchEvents extends EventEvent {
  final String query;

  SearchEvents(this.query);
}

class EventFriendsCount extends EventEvent {
  final String eventId;

  EventFriendsCount(this.eventId);
}

