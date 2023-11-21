import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../app_layout.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({Key? key}) : super(key: key);

  @override
  QrCodeScreenState createState() => QrCodeScreenState();
}

class QrCodeScreenState extends State<QrCodeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                child: const Row(
                  children: [
                    Text(
                      'Club Qr Code',
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
            Gap(AppLayout.getHeight(350)),
            const Center(
              child: Text(
                'Coming Soon!',
                style: TextStyle(
                  color: Color(0xFF09152D),
                  fontSize: 24,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
