import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'event_event.dart';
import 'event_model.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  EventBloc(this.firestore, this.storage) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    try {
      emit(EventsLoading());
      final events = await _fetchEvents();
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<List<EventModel>> _fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    final eventsSnapshot = await firestore
        .collection('events')
        .where('organizerId', isEqualTo: user!.uid)
        .get();

    List<EventModel> events = [];
    for (var doc in eventsSnapshot.docs) {
      // get attendee count and pending attendee count here
      final attendeesCount = await getAttendeeCount(doc.id);
      final pendingAttendeesCount = await getPendingAttendeeCount(doc.id);

      final clubSnapshot = await firestore.collection('clubs').doc(user.uid).get();

      events.add(
        EventModel(
          id: doc.id,
          name: doc['name'],
          imageUrl: doc['image_low_url'],
          imageUrlHigh : doc['image_url'],
          organizerImageUrl: clubSnapshot['image_low_url'],
          organizer: doc['organizer'],
          date: doc['date'],
          price: doc['price'].toInt(),
          about: doc['about'],
          address: doc['address'],
          location: doc['location'],
          organizerId: doc['organizerId'],
          paymentMethod: doc['payment_method'],
          time: doc['time'],
          attendeesCount: attendeesCount,
          pendingAttendeesCount: pendingAttendeesCount,
        ),
      );
    }
    return events;
  }

  Future<int> getAttendeeCount(String eventId) async {
    final attendeesSnapshot = await firestore.collection('events').doc(eventId).collection('Attendees').get();

    int totalCount = 0;

    for (var doc in attendeesSnapshot.docs) {
      int quantity = doc.data()['quantity'] ?? 0;
      totalCount += quantity;
    }

    return totalCount;
  }


  Future<int> getPendingAttendeeCount(String eventId) async {
    final attendeesSnapshot = await firestore.collection('events').doc(eventId).collection('Attendees').get();

    int totalCount = 0;

    for (var doc in attendeesSnapshot.docs) {
      if (doc['status'] == 'pending') {
        int quantity = doc.data()['quantity'] ?? 0;
        totalCount += quantity;
      }
    }

    return totalCount;
  }

}
