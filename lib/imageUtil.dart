import 'dart:io';
import 'package:image/image.dart';

Future<File> resizeAndCompressImage(File originalImageFile, String targetPath) async {
  Image? image = decodeImage(await originalImageFile.readAsBytes());

  // Resize the image to a smaller width/height. Maintain the aspect ratio.
  const int targetSize = 200;
  double aspectRatio = image!.width / image!.height;
  if (aspectRatio > 1) {
    // Landscape or square image: constrain width and let height adjust to keep the aspect ratio.
    image = copyResize(image, width: targetSize);
  } else {
    // Portrait image: constrain height and let width adjust to keep the aspect ratio.
    image = copyResize(image, height: targetSize);
  }

  // Compress the image as a lower quality JPEG.
  List<int> compressedBytes = encodeJpg(image, quality: 100);

  // Write the bytes to a new file.
  File resizedImageFile = File(targetPath);
  await resizedImageFile.writeAsBytes(compressedBytes);

  return resizedImageFile;
}
