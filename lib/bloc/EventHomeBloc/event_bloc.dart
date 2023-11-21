import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../EventHomeBloc/event_model.dart';
import '../EventHomeBloc/event_state.dart';
import '../EventHomeBloc/event_event.dart';

class EventBloc extends Bloc<EventEvent, EventState> {

  late List<EventModel> _allEvents = [];
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  EventBloc(this.firestore, this.storage) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<SearchEvents>(_onSearchEvents);
    on<EventFriendsCount>(_onEventFriendsCount);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    try {
      emit(EventsLoading());
      _allEvents = await _fetchEvents();
      emit(EventsLoaded(events: _allEvents));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<void> _onSearchEvents(SearchEvents event, Emitter<EventState> emit) async {
    try {
      emit(EventsLoading());
      final results = _allEvents.where((eventModel) =>
          eventModel.name.toLowerCase().startsWith(event.query.toLowerCase())
      ).toList();
      emit(EventsLoaded(events: results));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<void> _onEventFriendsCount(EventFriendsCount event, Emitter<EventState> emit) async {
    try {
      emit(EventsLoading());
      int friendsCount = await _fetchEventFriendsCount(event.eventId);
      emit(EventFriendsCountLoaded(count: friendsCount));
    } catch (e) {
      emit(EventsError(message: e.toString()));
    }
  }

  Future<List<EventModel>> _fetchEvents() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Get the list of events that the user is registered for
    final registeredEventsSnapshot = await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('Registered Events')
        .get();

    // Convert the documents into a Set for easier lookup
    final registeredEventIds = registeredEventsSnapshot.docs.map((doc) => doc.id).toSet();

    final eventsSnapshot = await firestore
        .collection('events')
        .orderBy('date')
        .get();

    List<EventModel> events = [];
    for (var doc in eventsSnapshot.docs) {
      // Skip the event if the user is registered for it
      if (registeredEventIds.contains(doc.id)) {
        continue;
      }

      Timestamp eventTimestamp = doc['date'];
      DateTime eventDateTime = eventTimestamp.toDate();

      // If the event time is earlier than the current time, skip this event
      if (DateTime.now().isAfter(eventDateTime)) {
        continue;
      }

      final clubSnapshot = await firestore.collection('clubs').doc(doc['organizerId']).get();

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
        ),
      );
    }

    return events;
  }



  Future<int> _fetchEventFriendsCount(String eventId) async {
    print("IN _fetchEventFriendsCount");
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch attendees of the event
    final attendeesSnapshot = await firestore
        .collection('events')
        .doc(eventId)
        .collection('Attendees')
        .get();

    // Fetch friends of the current user
    final friendsSnapshot = await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('Friends')
        .get();

    List<String> attendeeIds = attendeesSnapshot.docs.map((doc) => doc.id).toList();
    List<String> friendIds = friendsSnapshot.docs.map((doc) => doc.id).toList();

    // Count the number of friends attending the event
    int friendsCount = attendeeIds.where((id) => friendIds.contains(id)).length;
    return friendsCount;
  }
}