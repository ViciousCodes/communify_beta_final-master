import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/Feed/individual_event_gallery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EventGallery extends StatefulWidget {
  const EventGallery({Key? key}) : super(key: key);

  @override
  EventGalleryState createState() => EventGalleryState();
}

class EventGalleryState extends State<EventGallery> with AutomaticKeepAliveClientMixin<EventGallery>{
  List<EventSummaryModel> events = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchEventsWithTopImages();
  }

  _fetchEventsWithTopImages() async {
    setState(() {
      isLoading = true;
    });

    List<EventSummaryModel> fetchedEvents = [];

    // Fetch all events (or limit them based on your requirements).
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance.collection('events').get();

    for (var eventData in eventSnapshot.docs) {
      String eventId = eventData.id;
      String eventName = eventData['name'];

      // For each event, fetch its most liked image.
      QuerySnapshot imagesSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('images')
          .orderBy('likesCount', descending: true)
          .limit(1)
          .get();

      if (imagesSnapshot.docs.isNotEmpty) {
        String topImageUrl = imagesSnapshot.docs.first['imageUrl'];
        fetchedEvents.add(EventSummaryModel(
          eventId: eventId,
          eventName: eventName,
          topImageUrl: topImageUrl,
        ));
      } else {
        fetchedEvents.add(EventSummaryModel(
          eventId: eventId,
          eventName: eventName,
          showPlaceholder: true,
        ));
      }
    }

    setState(() {
      events = fetchedEvents;
      isLoading = false; // set loading state to false when fetching completes
    });
  }

  Future<void> _refreshEvents() async {
    await _fetchEventsWithTopImages();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(10), right: AppLayout.getWidth(10)),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'commUnified',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 30,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(AppLayout.getHeight(10)),
            Expanded(
              child: isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : RefreshIndicator(
                    color: const Color(0xFF09152D),
                    onRefresh: _refreshEvents,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IndividualEventGallery(eventId: event.eventId),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: 200.0, // adjust the height as required
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                ),
                                child: ClipRRect(
                                  child: event.showPlaceholder ?
                                    const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.image_not_supported, size: 75.0, color: Color(0xFF09152D)), // Placeholder icon
                                          Text(
                                            "Be the first to upload an image",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF09152D),
                                              fontSize: 18,
                                              fontFamily: 'Satoshi',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) :
                                    Image.network(
                                      event.topImageUrl!,
                                      fit: BoxFit.cover,
                                    ), // Most liked image for the event
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: AppLayout.getHeight(40),
                                padding: const EdgeInsets.only(top: 5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF09152D),
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                ),
                                child: Text(
                                  event.eventName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Gap(AppLayout.getHeight(20))
                            ],
                          ),
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class EventSummaryModel {
  final String eventId;
  final String eventName;
  final String? topImageUrl;
  final bool showPlaceholder;

  EventSummaryModel({
    required this.eventId,
    required this.eventName,
    this.topImageUrl,
    this.showPlaceholder = false,
  });
}

