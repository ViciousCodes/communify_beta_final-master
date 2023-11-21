import '../EventHomeBloc/event_model.dart';

abstract class EventState {}

class EventsInitial extends EventState {}

class EventsLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventModel> events;
  EventsLoaded({required this.events});
}

class EventsError extends EventState {
  final String message;
  EventsError({required this.message});
}

class EventFriendsCountLoaded extends EventState {
  final int count;

  EventFriendsCountLoaded({required this.count});
}