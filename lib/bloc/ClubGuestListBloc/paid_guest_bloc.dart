// PaidGuestEvent
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'guest_model.dart';

abstract class PaidGuestEvent {}

class LoadPaidGuests extends PaidGuestEvent {
  final String eventId;

  LoadPaidGuests({required this.eventId});
}

class SearchPaidGuests extends PaidGuestEvent {
  final String searchText;

  SearchPaidGuests({required this.searchText});
}

// PaidGuestState
abstract class PaidGuestState {}

class PaidGuestInitial extends PaidGuestState {}

class PaidGuestLoading extends PaidGuestState {}

class PaidGuestLoaded extends PaidGuestState {
  final List<Guest> guests;

  PaidGuestLoaded({required this.guests});
}

class PaidGuestError extends PaidGuestState {
  final String message;

  PaidGuestError({required this.message});
}

// PaidGuestBloc
class PaidGuestBloc extends Bloc<PaidGuestEvent, PaidGuestState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  String _searchText = "";
  List<Guest> _allGuests = [];

  PaidGuestBloc() : super(PaidGuestLoading()) {
    on<LoadPaidGuests>((event, emit) async {
      emit(PaidGuestLoading());
      try {
        _allGuests = await _fetchPaidGuests(event.eventId);
        emit(PaidGuestLoaded(guests: _allGuests));
      } catch (e) {
        emit(PaidGuestError(message: e.toString()));
      }
    });

    on<SearchPaidGuests>((event, emit) async {
      _searchText = event.searchText;
      emit(PaidGuestLoaded(guests: _filterGuests()));  // Emit only the filtered guests
    });
  }

  Future<List<Guest>> _fetchPaidGuests(String eventId) async {
    List<Guest> guests = [];

    // Fetch the guests from Firestore where status is 'paid'
    // Assume Firestore instance is already available
    QuerySnapshot attendeesSnapshot = await firestore
        .collection('events')
        .doc(eventId)
        .collection('Attendees')
        .where('status', isEqualTo: 'paid')
        .get();

    for (var doc in attendeesSnapshot.docs) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(doc.id).get();
      Guest guest = Guest.fromFirestore(userDoc);
      guests.add(guest);
    }

    return guests;
  }

  List<Guest> _filterGuests() {
    if (_searchText.isEmpty) {
      return _allGuests;
    } else {
      return _allGuests.where((guest) =>
          ("${guest.firstName} ${guest.lastName}").toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }
  }
}

