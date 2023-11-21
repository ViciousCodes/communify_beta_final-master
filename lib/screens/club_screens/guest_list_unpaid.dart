import 'package:cached_network_image/cached_network_image.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:communify_beta_final/bloc/ClubGuestListBloc/guest_bloc.dart';
import 'package:communify_beta_final/bloc/ClubGuestListBloc/guest_event.dart';
import 'package:communify_beta_final/bloc/ClubGuestListBloc/guest_state.dart';

class GuestListUnpaid extends StatefulWidget {
  final String eventId;

  const GuestListUnpaid({Key? key, required this.eventId}) : super(key: key);

  @override
  GuestListUnpaidState createState() => GuestListUnpaidState();
}

class GuestListUnpaidState extends State<GuestListUnpaid>  {
  late TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: "")
      ..addListener(() {
        context.read<GuestBloc>().add(SearchGuests(searchText: _search.text));
      });
  }

  @override
  void dispose() {
    _search.dispose(); // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestBloc, GuestState>(
      builder: (context, state) {
        if (state is GuestLoading) {
          return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
        } else if (state is GuestLoaded) {
          var guestBloc = BlocProvider.of<GuestBloc>(context);
          return GestureDetector(  // Wrap your Column with GestureDetector
            onTap: () {
              FocusScope.of(context).unfocus();  // Hide keyboard
            },
            child: Column(
              children: [
                Gap(AppLayout.getHeight(15)),
                CupertinoTextField(
                  controller: _search,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(5)),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: Color(0xFF677489),
                      size: 22,  // adjust as needed
                    ),
                  ),
                  placeholder: "Search...",
                  placeholderStyle: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 15,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 15,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(width: 1, color: const Color(0xFF677489)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.only(left: AppLayout.getWidth(5), top: AppLayout.getHeight(7), bottom: AppLayout.getHeight(7)),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<GuestBloc>().add(LoadGuests(eventId: widget.eventId));
                    },
                    color: const Color(0xFF09152D),
                    child:
                      state.guests.isEmpty ?
                      Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_add_disabled_rounded,
                                color: Color(0xFF09152D),
                                size: 100.0,
                              ),
                              const Text(
                                'No Unpaid Guests',
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
                                    context.read<GuestBloc>().add(LoadGuests(eventId: widget.eventId));
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
                        itemCount: state.guests.length,
                        itemBuilder: (context, index) {
                          final guest = state.guests[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ListTile(
                              leading: guest.imageUrl == '' ?
                              CircleAvatar(
                                backgroundColor: const Color(0xFFA8B2C6),
                                radius: 30.0,
                                child: Text(
                                  "${guest.firstName[0].toUpperCase()}${guest.lastName[0].toUpperCase()}",
                                  style: const TextStyle(
                                    color: Color(0xFF09152D),
                                    fontSize: 25,
                                    fontFamily: 'Satoshi',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ) :
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: CachedNetworkImageProvider(guest.imageUrl),
                              ),
                              title: Text(
                                "${guest.firstName} ${guest.lastName} - \$${guest.price}",
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 17,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                "Received: ${guest.receivedTime}",
                                style: const TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 13,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  guestBloc.paidGuests.contains(guest.id) ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: guestBloc.paidGuests.contains(guest.id) ? const Color(0xFF09152D) : const Color(0xFFA8B2C6),
                                  size: 30,
                                ),
                                onPressed: () {
                                  context.read<GuestBloc>().add(UpdateGuestStatus(
                                    eventId: widget.eventId,
                                    guestId: guest.id,
                                    status: guestBloc.paidGuests.contains(guest.id) ? 'pending' : 'paid',
                                  ));
                                },
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is GuestError) {
          return Text('Error: ${state.message}');
        }
        return Container();
      },
    );
  }
}