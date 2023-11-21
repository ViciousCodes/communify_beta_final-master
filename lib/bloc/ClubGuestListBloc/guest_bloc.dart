import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'guest_event.dart';
import 'guest_model.dart';
import 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final String eventId;
  List<Guest> _allGuests = [];
  Set<String> paidGuests = <String>{};
  String _searchText = "";

  GuestBloc({required this.eventId}) : super(GuestInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<SearchGuests>(_onSearchGuests);
    on<UpdateGuestStatus>(_onUpdateGuestStatus);
  }

  Future<void> _onLoadGuests(LoadGuests event, Emitter<GuestState> emit) async {
    try {
      emit(GuestLoading());
      _allGuests = await _fetchGuests(eventId);
      emit(GuestLoaded(guests: _allGuests));
    } catch (e) {
      emit(GuestError(message: e.toString()));
    }
  }

  Future<void> _onSearchGuests(SearchGuests event, Emitter<GuestState> emit) async {
    _searchText = event.searchText;
    emit(GuestLoaded(guests: _filterGuests()));
  }

  Future<void> _onUpdateGuestStatus(UpdateGuestStatus event, Emitter<GuestState> emit) async {
    await _updateGuestStatus(event.eventId, event.guestId, event.status);
    // Update the status in local data
    if (event.status == 'paid') {
      paidGuests.add(event.guestId);
    } else {
      paidGuests.remove(event.guestId);
    }
    // Re-emit the current state to update the UI
    emit(GuestLoaded(guests: _filterGuests()));
  }


  Future<List<Guest>> _fetchGuests(String eventId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Guest> guests = [];

    // Fetch the event document
    DocumentSnapshot eventDoc = await firestore.collection('events').doc(eventId).get();

    // Get the price from the event document
    var eventPrice = (eventDoc.data() as Map<String, dynamic>)['price'];

    // 'Attendees' is a sub-collection in an event document
    QuerySnapshot attendeesSnapshot = await firestore
        .collection('events')
        .doc(eventId)
        .collection('Attendees')
        .where('status', isEqualTo: 'pending')
        .get();

    for (QueryDocumentSnapshot attendeeDoc in attendeesSnapshot.docs) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(attendeeDoc.id).get();
      Guest guest = Guest.fromFirestore(userDoc);
      guest.receivedTime = attendeeDoc['received_time'];
      guest.price = eventPrice.toInt() * attendeeDoc['quantity'].toInt();
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

  // Updates the status field of a specific guest in the Firestore database
  Future<void> _updateGuestStatus(String eventId, String guestId, String status) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('Attendees')
        .doc(guestId)
        .update({'status': status});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(guestId)
        .collection('Registered Events')
        .doc(eventId)
        .update({'status': status});
    // Update the status in local data
    _allGuests.firstWhere((guest) => guest.id == guestId).status = status;
  }
}
