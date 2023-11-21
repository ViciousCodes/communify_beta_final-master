import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../app_layout.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_event.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_state.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_bloc.dart';
import 'event_details.dart';

class EventListScreen extends StatelessWidget {
  final EventBloc bloc;

  const EventListScreen({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventsInitial) {
          context.read<EventBloc>().add(LoadEvents());
          return const CircularProgressIndicator();
        } else if (state is EventsLoading) {
          return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
        } else if (state is EventsLoaded) {
          return Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<EventBloc>().add(LoadEvents());
              },
              color: const Color(0xFF09152D),
              child:
                state.events.isEmpty ?
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          color: Color(0xFF09152D),
                          size: 100.0,
                        ),
                        const Text(
                          'No Events',
                          style: TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 24,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          iconSize: 40,
                          onPressed: () {
                            context.read<EventBloc>().add(LoadEvents());
                          },
                          icon: const FittedBox(
                            fit: BoxFit.contain,
                            child: Icon(CupertinoIcons.refresh_circled_solid, color: Color(0xFF09152D)),
                          )
                        )
                      ],
                    )
                  ) :
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      final event = state.events[index];
                      return SizedBox(
                        height: AppLayout.getHeight(100),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return EventDetailsScreen(event: event, bloc: bloc);
                            }));
                          },
                          child: Card(
                            elevation: 0,
                            child: Row(
                              children: [
                                Container(
                                  width: AppLayout.getWidth(70),
                                  height: AppLayout.getHeight(80),
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(event.imageUrl),
                                      fit: BoxFit.fill,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Gap(AppLayout.getWidth(10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Gap(AppLayout.getHeight(10)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: AppLayout.getWidth(215),
                                          child: Text(
                                            event.name,
                                            style: const TextStyle(
                                              color: Color(0xFF09152D),
                                              fontSize: 17,
                                              fontFamily: 'Satoshi',
                                              fontWeight: FontWeight.w700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          event.price == 0 ? "FREE" : "\$${event.price.toString()}",
                                          style: const TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 17,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                    Gap(AppLayout.getHeight(5)),
                                    SizedBox(
                                      width: AppLayout.getWidth(250),
                                      child: Text(
                                        "By ${event.organizer}",
                                        style: const TextStyle(
                                          color: Color(0xFF677489),
                                          fontSize: 15,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Gap(AppLayout.getHeight(5)),
                                    Row(
                                      children: [
                                        const Icon(CupertinoIcons.calendar, color: Color(0xFF677489)),
                                        Gap(AppLayout.getWidth(5)),
                                        Text(
                                          DateFormat('MMM d \'at\' h:mm a').format(event.date.toDate()),
                                          style: const TextStyle(
                                            color: Color(0xFF677489),
                                            fontSize: 15,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ),
          );
        } else if (state is EventsError) {
          return Text(state.message);
        } else {
          return Container();
        }
      },
    );
  }
}