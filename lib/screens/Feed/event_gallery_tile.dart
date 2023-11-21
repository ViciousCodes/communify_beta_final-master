import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/full_screen_image.dart';
import 'package:communify_beta_final/screens/Feed/image_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventImageTile extends StatefulWidget {
  final ImageModel image;
  final String eventId;

  const EventImageTile({super.key, required this.image, required this.eventId});

  @override
  EventImageTileState createState() => EventImageTileState();
}

class EventImageTileState extends State<EventImageTile> {
  bool isLiked = false;
  int? likesCount;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    likesCount = widget.image.likesCount; // Initialize with the count from the image model
    _checkIfLiked(); // Check if the user has already liked the image
  }

  void _checkIfLiked() async {
    DocumentReference docRef = _firestore
        .collection('events')
        .doc(widget.eventId)
        .collection('images')
        .doc(widget.image.id);

    DocumentSnapshot snapshot = await docRef.collection('likedBy').doc(FirebaseAuth.instance.currentUser!.uid).get();

    setState(() {
      isLiked = snapshot.exists; // if the document exists, it means the user has liked the image
    });
  }

  void _toggleLike() async {
    DocumentReference docRef = _firestore
        .collection('events')
        .doc(widget.eventId)
        .collection('images')
        .doc(widget.image.id);

    int newLikes = 0;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      newLikes = (snapshot.data() as Map<String, dynamic>)['likesCount'] ?? 0;

      if (isLiked) {
        // Unlike the image
        newLikes -= 1;
        docRef.collection('likedBy').doc(FirebaseAuth.instance.currentUser!.uid).delete(); // remove user UID
      } else {
        // Like the image
        newLikes += 1;
        docRef.collection('likedBy').doc(FirebaseAuth.instance.currentUser!.uid).set({}); // add user UID
      }

      transaction.update(docRef, {'likesCount': newLikes});
    });

    setState(() {
      isLiked = !isLiked;
      likesCount = newLikes;
    });
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(imageUrl: widget.image.imageUrl),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The actual image
          Positioned.fill(child: Image(image: CachedNetworkImageProvider(widget.image.imageUrl), fit: BoxFit.cover)),

          // Like button and count
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppLayout.getHeight(5)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, const Color(0xFF09152D).withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                  onPressed: _toggleLike, // Function to handle liking/unliking
                ),
                Text(
                  likesCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
