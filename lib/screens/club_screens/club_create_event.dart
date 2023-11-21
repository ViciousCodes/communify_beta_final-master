import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import '../../app_layout.dart';
import '../../bottom_nav_club.dart';
import '../../imageUtil.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  AddEventScreenState createState() => AddEventScreenState();
}

class AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _eventNameController;
  late TextEditingController _priceController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  File? _imageFile;
  late DateTime curTime = DateTime.now();
  late DateTime _dateTime = curTime;


  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController();
    _priceController = TextEditingController();
    _paymentMethodController = TextEditingController();
    _locationController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
    }
  }

  createEvent() async {

    if (_eventNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _paymentMethodController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Missing Fields'),
            content: const Text('Please fill in all required fields.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }


    if (_formKey.currentState!.validate()) {
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
      try {
        final userDoc = await _firestore.collection('clubs').doc(FirebaseAuth.instance.currentUser!.uid).get();
        final clubName = userDoc['club_name'] as String;
        final eventDocRef = await _firestore.collection('events').add({
          'name': _eventNameController.text,
          'organizer' : clubName,
          'organizerId' : FirebaseAuth.instance.currentUser!.uid,
          'date': Timestamp.fromDate(_dateTime),
          'time' : DateFormat('h:mm a').format(_dateTime),
          'price' : double.tryParse(_priceController.text) ?? 0.0,
          'payment_method' : _paymentMethodController.text,
          'location' : _locationController.text,
          'address' : _addressController.text,
          'about' : _descriptionController.text,
          'image_url' : '',
          'image_low_url' : ''
        });

        final eventId = eventDocRef.id;

        final Reference storageReference = FirebaseStorage.instance.ref().child('event_images').child('${FirebaseAuth.instance.currentUser!.uid}${DateFormat('MMMM-dd-y-H:mm:ss').format(Timestamp.fromDate(_dateTime).toDate())}');
        final Reference storageReferenceLow = FirebaseStorage.instance.ref().child('event_images_low').child('${FirebaseAuth.instance.currentUser!.uid}${DateFormat('MMMM-dd-y-H:mm:ss').format(Timestamp.fromDate(_dateTime).toDate())}');

        final dir = await getTemporaryDirectory();

        final targetPath = path.join(dir.absolute.path, "${eventId}_compressed.jpg");

        File compressedImage = await resizeAndCompressImage(_imageFile!, targetPath);

        await storageReference.putFile(_imageFile!);
        await storageReferenceLow.putFile(compressedImage);

        String imageUrl = await storageReference.getDownloadURL();
        String imageLowUrl = await storageReferenceLow.getDownloadURL();

        await _firestore.collection('events').doc(eventId).update({
          'image_url': imageUrl, // Save the image URL to Firestore
          'image_low_url': imageLowUrl, // Save the low resolution image URL to Firestore
        });

        if (context.mounted) Navigator.push(context, CupertinoPageRoute(builder: (context) => const BottomNavClub()));

      } catch (e) {

        if (context.mounted) {
          Navigator.of(context).pop();
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()), // Show the error message to the user
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButton(color: Color(0xFF09152D)),
                        Text(
                          'Create Event',
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
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Placeholder color
                      borderRadius: BorderRadius.circular(20),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover,)
                          : null,
                    ),
                    child: _imageFile == null ? const Icon(CupertinoIcons.camera, size: 50, color: Color(0xFF677489)) : null,
                  ),
                ),
                CupertinoButton(
                  onPressed: pickImage,
                  child: const Text(
                    'Add Picture',
                    style: TextStyle(
                      color: Color(0xFF09152D),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CupertinoTextField(
                  controller: _eventNameController,
                  placeholder: "Event Name",
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      CupertinoIcons.calendar,
                      color: Color(0xFF677489),
                    ),
                  ),
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
                            initialDateTime: curTime,
                            minimumDate: curTime,
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
                          _dateTime == curTime ?
                          "Date & Time" :
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
                  controller: _priceController,
                  placeholder: "Price",
                  keyboardType: TextInputType.number,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      Icons.price_change_outlined,
                      color: Color(0xFF677489),
                    ),
                  ),
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
                Gap(AppLayout.getHeight(20)),
                CupertinoTextField(
                  controller: _paymentMethodController,
                  placeholder: "Payment Method",
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      CupertinoIcons.creditcard,
                      color: Color(0xFF677489),
                    ),
                  ),
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
                Gap(AppLayout.getHeight(20)),
                CupertinoTextField(
                  controller: _locationController,
                  placeholder: "Location",
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      CupertinoIcons.map_pin,
                      color: Color(0xFF677489),
                    ),
                  ),
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
                Gap(AppLayout.getHeight(20)),
                CupertinoTextField(
                  controller: _addressController,
                  placeholder: "Address",
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      CupertinoIcons.map,
                      color: Color(0xFF677489),
                    ),
                  ),
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
                Gap(AppLayout.getHeight(20)),
                CupertinoTextField(
                  controller: _descriptionController,
                  placeholder: "Event Description",
                  maxLines: 3,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      Icons.abc_outlined,
                      color: Color(0xFF677489),
                    ),
                  ),
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
                Gap(AppLayout.getHeight(20)),
                CupertinoButton(
                  onPressed: createEvent,
                  child: Center(
                    child: Container(
                      width: AppLayout.getWidth(150), // Adjust the width as desired
                      height: AppLayout.getHeight(50), // Adjust the height as desired
                      decoration: BoxDecoration(
                        color: const Color(0xFF09152D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Stack(
                        children: [
                          Center(
                            child: Text(
                              'Create Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(50)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
