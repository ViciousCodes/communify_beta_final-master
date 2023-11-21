import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AppLayout{
  static const double designScreenWidth = 390.0;  // iPhone 12 Pro width in logical points
  static const double designScreenHeight = 844.0;

  static getSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static getScreenHeight() {
    return Get.height;
  }

  static getScreenWidth() {
    return Get.width;
  }

  static getHeight(double pixels) {
    double screenHeight = getScreenHeight();
    return (pixels / designScreenHeight) * screenHeight;
  }

  static getWidth(double pixels) {
    double screenWidth = getScreenWidth();
    return (pixels / designScreenWidth) * screenWidth;
  }
  static newGetWidth(double fraction) {
    double x = getScreenWidth();
    return x * fraction;
  }
  static newGetHeight(double fraction) {
    double x = getScreenHeight();
    return x * fraction;
  }
}