import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../app_layout.dart';
import '../../bloc/ClubGuestListBloc/paid_guest_bloc.dart';

class GuestListPaid extends StatefulWidget {
  final String eventId;

  const GuestListPaid({Key? key, required this.eventId}) : super(key: key);

  @override
  GuestListPaidState createState() => GuestListPaidState();
}

class GuestListPaidState extends State<GuestListPaid>  {
  late TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: "")..addListener(() {
      context.read<PaidGuestBloc>().add(SearchPaidGuests(searchText: _search.text));
    });

    // Load the paid guests initially
    context.read<PaidGuestBloc>().add(LoadPaidGuests(eventId: widget.eventId));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaidGuestBloc, PaidGuestState>(
      builder: (context, state) {
        if (state is PaidGuestLoading) {
          return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
        } else if (state is PaidGuestLoaded) {
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
                    context.read<PaidGuestBloc>().add(LoadPaidGuests(eventId: widget.eventId));
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
                              'No Paid Guests',
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
                                  context.read<PaidGuestBloc>().add(LoadPaidGuests(eventId: widget.eventId));
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
                              "${guest.firstName} ${guest.lastName}",
                              style: const TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 18,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: const Icon(Icons.check_box, color: Color(0xFF09152D))
                          ),
                        );
                      },
                    ),
                ),
              ),
            ],
            ),
          );
        } else if (state is PaidGuestError) {
          return Text('Error: ${state.message}');
        }
        return Container();
      },
    );
  }
}
