import 'guest_model.dart';

abstract class GuestState {}

class GuestInitial extends GuestState {}

class GuestLoading extends GuestState {}

class GuestLoaded extends GuestState {
  final List<Guest> guests;

  GuestLoaded({required this.guests});
}

class GuestError extends GuestState {
  final String message;

  GuestError({required this.message});
}