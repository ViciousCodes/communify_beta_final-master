import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/Feed/event_gallery_tile.dart';
import 'package:communify_beta_final/screens/Feed/image_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IndividualEventGallery  extends StatefulWidget {
  final String eventId;

  const IndividualEventGallery ({super.key, required this.eventId});

  @override
  IndividualEventGalleryState createState() => IndividualEventGalleryState();
}

class IndividualEventGalleryState  extends State<IndividualEventGallery> with AutomaticKeepAliveClientMixin<IndividualEventGallery>{
  List<ImageModel> images = []; // ImageModel is a class we'd define for image-related data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  void _fetchImages() async {
    QuerySnapshot snapshot = await _firestore
        .collection('events')
        .doc(widget.eventId)
        .collection('images')
        .orderBy('timestamp', descending: true) // Newest images first
        .get();

    images = snapshot.docs.map((doc) {
      return ImageModel(
        id: doc.id,
        uploaderID: doc['uploaderID'],
        imageUrl: doc['imageUrl'],
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
        likesCount: doc['likesCount'],
      );
    }).toList();

    setState(() {});
  }

  void _uploadImage() async {
    // 1. Use an image picker to get image (you might need to import a package like image_picker)
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);

      // 2. Upload the image to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('event_images').child(DateTime.now().toString());
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();

      // 3. Save to Firestore
      await _firestore.collection('events').doc(widget.eventId).collection('images').add({
        'uploaderID': FirebaseAuth.instance.currentUser!.uid,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'likesCount': 0,
      });

      // Refresh the images
      _fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppLayout.getWidth(10),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppLayout.getHeight(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const BackButton(color: Color(0xFF09152D)),
                    const Text(
                      'Event Gallery',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 30,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.upload_file, color: Color(0xFF09152D), size: 30,),
                      onPressed: _uploadImage, // A function to handle image uploading
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: AppLayout.getHeight(10)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Adjust based on your design
                  childAspectRatio: 1, // Square images
                  mainAxisSpacing: AppLayout.getHeight(10),
                  crossAxisSpacing: AppLayout.getWidth(10),
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return EventImageTile(image: images[index], eventId: widget.eventId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
