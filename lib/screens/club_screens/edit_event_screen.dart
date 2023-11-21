import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../app_layout.dart';
import '../../bottom_nav_club.dart';
import '../../imageUtil.dart';

class EditEventScreen extends StatefulWidget {
  final String oldName;
  final Timestamp oldDate;
  final String oldTime;
  final String oldLocation;
  final String oldAddress;
  final String oldAbout;
  final String eventId;
  final Timestamp dateTime;
  const EditEventScreen({Key? key, required this.oldAbout, required this.eventId, required this.dateTime, required this.oldName, required this.oldDate, required this.oldTime, required this.oldLocation, required this.oldAddress}) : super(key: key);

  @override
  EditEventScreenState createState() => EditEventScreenState();
}

class EditEventScreenState extends State<EditEventScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();

  late DateTime curTime = widget.oldDate.toDate();
  late DateTime _dateTime = curTime;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.oldAbout);
    _nameController = TextEditingController(text: widget.oldName);
    _locationController = TextEditingController(text: widget.oldLocation);
    _addressController = TextEditingController(text: widget.oldAddress);
  }

  File? _imageFile;

  // You'll need to implement these methods (pickImage and saveProfile) according to your application.
  Future<void> pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
    }
  }

  Future<void> saveEvent() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    String userUID = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: AppLayout.getWidth(100),
            height: AppLayout.getHeight(100),
            child: const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D))),
          ),
        );
      },
    );

    String newImageUrlHigh = '';
    String newImageUrlLow = '';

    // Upload the new image to Firebase Storage
    if (_imageFile != null) {
      // Delete the old image from Firebase Storage
      final String oldImagePathHigh = "event_images/$userUID${DateFormat('MMMM-dd-y-H:mm:ss').format(widget.dateTime.toDate())}";
      Reference oldImageRefHigh = firebaseStorage.ref().child(oldImagePathHigh);

      // Delete the old image from Firebase Storage
      final String oldImagePathLow = "event_images_low/$userUID${DateFormat('MMMM-dd-y-H:mm:ss').format(widget.dateTime.toDate())}";
      Reference oldImageRefLow = firebaseStorage.ref().child(oldImagePathLow);

      await oldImageRefHigh.delete();
      await oldImageRefLow.delete();

      final String newImagePathHigh = "event_images/$userUID${DateFormat('MMMM-dd-y-H:mm:ss').format(widget.dateTime.toDate())}";
      Reference newImageRefHigh = firebaseStorage.ref().child(newImagePathHigh);

      final String newImagePathLow = "event_images_low/$userUID${DateFormat('MMMM-dd-y-H:mm:ss').format(widget.dateTime.toDate())}";
      Reference newImageRefLow = firebaseStorage.ref().child(newImagePathLow);

      final dir = await getTemporaryDirectory();

      final targetPath = path.join(dir.absolute.path, "${widget.eventId}_compressed.jpg");

      File compressedImage = await resizeAndCompressImage(_imageFile!, targetPath);

      await newImageRefHigh.putFile(_imageFile!);
      await newImageRefLow.putFile(compressedImage);

      // Update 'image_low_url' and 'image_url' fields in the 'events' collection
      newImageUrlHigh = await newImageRefHigh.getDownloadURL();
      newImageUrlLow = await newImageRefLow.getDownloadURL();

      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'image_url': newImageUrlHigh,
        'image_low_url': newImageUrlLow,
      });
    }

    // Update the event in Firestore
    await firestore.collection('events').doc(widget.eventId).update({
      'name' : _nameController.text,
      'location' : _locationController.text,
      'address' : _addressController.text,
      'date' : Timestamp.fromDate(_dateTime),
      'time' : DateFormat('h:mm a').format(_dateTime),
      'about': _descriptionController.text,
    });

    // Fetch all attendees of the event
    QuerySnapshot attendeesSnapshot = await firestore.collection('events').doc(widget.eventId).collection('Attendees').get();
    List<DocumentSnapshot> attendees = attendeesSnapshot.docs;

    // Loop through each attendee and update their 'Registered Events'
    for (DocumentSnapshot attendee in attendees) {
      String attendeeUID = attendee.id;

      await firestore.collection('users').doc(attendeeUID).collection('Registered Events').doc(widget.eventId).update({
        'name' : _nameController.text,
        'location' : _locationController.text,
        'date' : Timestamp.fromDate(_dateTime),
        'image_url' : newImageUrlHigh
      });
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => const BottomNavClub()),
              (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Padding(
          padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BackButton(color: Color(0xFF09152D)),
                          Text(
                            'Edit Event',
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
                  ),
                  Gap(AppLayout.getHeight(15)),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: AppLayout.getHeight(150),
                    decoration: ShapeDecoration(
                      color: Colors.grey[300],
                      image: _imageFile != null ?
                      DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      ) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _imageFile == null ?
                      const Icon(
                        Icons.image,  // replace with your placeholder icon
                        size: 100,
                        color: Colors.grey,
                      ) : null,
                  ),
                ),
                  Center(
                    child: CupertinoButton(
                      onPressed: () {
                        pickImage();
                      },
                      child: const Text(
                        'Change Event Image',
                        style: TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 18,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(10)),
                  CupertinoTextField(
                    controller: _nameController,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.calendar,
                        color: Color(0xFF677489),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                  ),
                  Gap(AppLayout.getHeight(20)),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext builder) {
                          return SizedBox(
                            height: MediaQuery.of(context).copyWith().size.height / 3,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              onDateTimeChanged: (dateTime) {
                                setState(() {
                                  _dateTime = dateTime;
                                });
                              },
                              initialDateTime: widget.oldDate.toDate(),
                              minimumDate: DateTime.now(),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: AppLayout.getHeight(50),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFF677489)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Gap(AppLayout.getWidth(20)),
                          const Icon(
                              CupertinoIcons.calendar_today,
                              color: Color(0xFF677489)
                          ),
                          Gap(AppLayout.getWidth(10)),
                          Text(
                            DateFormat('MMMM d, y \'at\' h:mm a').format(_dateTime),
                            style: const TextStyle(
                              color: Color(0xFF677489),
                              fontSize: 18,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(20)),
                  CupertinoTextField(
                    controller: _locationController,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.map_pin,
                        color: Color(0xFF677489),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                  ),
                  Gap(AppLayout.getHeight(20)),
                  CupertinoTextField(
                    controller: _addressController,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.map,
                        color: Color(0xFF677489),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                  ),
                  Gap(AppLayout.getHeight(20)),
                  CupertinoTextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'Confirm Password',
                    placeholderStyle: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                  ),
                  Gap(AppLayout.getHeight(10)),
                  CupertinoButton(
                    onPressed: () {
                      saveEvent();
                    },
                    child: Center(
                      child: Container(
                        width: AppLayout.getWidth(200),
                        height: AppLayout.getHeight(45),
                        decoration: BoxDecoration(
                          color: const Color(0xFF09152D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(10)),
                  CupertinoButton(
                    onPressed: () {
                      print("DELETE EVENT CLICKED");
                    },
                    child: Center(
                      child: Container(
                        width: AppLayout.getWidth(200),
                        height: AppLayout.getHeight(45),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Delete Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
