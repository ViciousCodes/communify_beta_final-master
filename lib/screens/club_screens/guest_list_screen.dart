import 'package:communify_beta_final/screens/club_screens/guest_list_paid.dart';
import 'package:communify_beta_final/screens/club_screens/guest_list_unpaid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../app_layout.dart';
import '../../bloc/ClubGuestListBloc/guest_bloc.dart';
import '../../bloc/ClubGuestListBloc/guest_event.dart';
import '../../bloc/ClubGuestListBloc/guest_state.dart';
import '../../bloc/ClubGuestListBloc/paid_guest_bloc.dart';

class GuestListScreen extends StatefulWidget {
  final String eventId;
  const GuestListScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  GuestListScreenState createState() => GuestListScreenState();
}

class GuestListScreenState extends State<GuestListScreen> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<GuestBloc>(
          create: (BuildContext context) => GuestBloc(eventId: widget.eventId)..add(LoadGuests(eventId: widget.eventId)),
        ),
        BlocProvider<PaidGuestBloc>(
          create: (BuildContext context) => PaidGuestBloc(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: CupertinoColors.white,
            body: Padding(
              padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: AppLayout.getHeight(80), bottom: AppLayout.getHeight(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButton(color: Color(0xFF09152D)),
                        Text(
                          'Guest List',
                           style: TextStyle(
                             color: Color(0xFF09152D),
                             fontSize: 24,
                             fontFamily: 'Satoshi',
                             fontWeight: FontWeight.w700,
                           ),
                         ),
                       ],
                    ),
                  ),
                  TabBar(
                    indicator: UnderlineTabIndicator(
                      insets: EdgeInsets.only(left: AppLayout.getWidth(30), right: AppLayout.getWidth(30)),
                      borderSide: const BorderSide(
                        color: Color(0xFF09152D),
                        width: 3,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const <Widget>[
                      Tab(
                        child: Text(
                          'UNPAID',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 18,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.16,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'PAID',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 18,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        GuestListUnpaid(eventId: widget.eventId),
                        GuestListPaid(eventId: widget.eventId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}

