import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../app_layout.dart';
import '../../bloc/ClubHomeBloc/event_bloc.dart';
import '../../bloc/ClubHomeBloc/event_event.dart';
import '../../bloc/ClubHomeBloc/event_state.dart';
import 'club_event_details.dart';

class EventListScreen extends StatelessWidget {
  final EventBloc bloc;

  const EventListScreen({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventBloc>(
      create: (context) => bloc,
      child: BlocBuilder<EventBloc, EventState>(
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
                          'No Created Events',
                          style: TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 22,
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
                      width: AppLayout.getWidth(330),
                      height: AppLayout.getHeight(100),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)));
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
                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Gap(AppLayout.getHeight(10)),
                                  SizedBox(
                                    width: AppLayout.getWidth(225),
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
                                  Gap(AppLayout.getHeight(5)),
                                  Text(
                                    "${event.attendeesCount} Registered",
                                    style: const TextStyle(
                                      color: Color(0xFF677489),
                                      fontSize: 15,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Gap(AppLayout.getHeight(5)),
                                  Text(
                                    "${event.pendingAttendeesCount} Unpaid",
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
      ),
    );
  }
}
