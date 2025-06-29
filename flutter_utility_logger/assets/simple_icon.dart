import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This is a helper script to generate a simple app icon
// You can run this to create a basic icon if you don't want to use the SVG approach

class IconGenerator {
  static Future<void> generateSimpleIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);

    // Background
    final paint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(const Offset(512, 512), 480, paint);

    // Meter dial
    final dialPaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(const Offset(512, 512), 320, dialPaint);

    final innerPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawCircle(const Offset(512, 512), 280, innerPaint);

    // Needle
    final needlePaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(512, 512);
    canvas.rotate(0.785398); // 45 degrees
    canvas.drawLine(const Offset(0, 0), const Offset(0, -272), needlePaint);
    canvas.restore();

    // Center circle
    final centerPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(const Offset(512, 512), 24, centerPaint);

    // Digital display
    final displayPaint = Paint()..color = const Color(0xFF1E293B);
    final displayRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(412, 600, 200, 80),
      const Radius.circular(12),
    );
    canvas.drawRRect(displayRect, displayPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final file = File('assets/app_icon.png');
    await file.writeAsBytes(bytes);

    print('Icon generated successfully at assets/app_icon.png');
  }
}

// To use this, you would need to:
// 1. Add this file to your project
// 2. Run: dart assets/simple_icon.dart
// 3. Then run: flutter pub run flutter_launcher_icons:main
