import 'package:communify_beta_final/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadImages();
    });
  }

  Future<void> _loadImages() async {
    try {
      await precacheImage(const AssetImage("assets/images/commUnifyCCursive2.jpg"), context);
      // Navigate to the Login screen once loading is complete.
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      print('Failed to load the image: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/commUnifyCCursive1.jpg', // Replace this with the path to your image
          width: 100, // Adjust size as needed
          height: 100, // Adjust size as needed
        ),
      ),
    );
  }
}
