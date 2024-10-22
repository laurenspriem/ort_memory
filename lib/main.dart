import 'dart:async';
import 'dart:developer' show log;
import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ort_memory/image_util.dart';
import 'package:ort_memory/network.dart';
import 'package:ort_memory/onnx/clip_image_encoder.dart';
import 'package:ort_memory/onnx/face_detection_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ONNX crash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter ONNX crash'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  bool _isRunning = false;

  Future<void> _runInfiniteIndexing(
      ui.Image decodedImage, Uint8List rawBytes) async {
    log("_runInfiniteIndexing called");
    try {
      log('start inference loop');
      while (true) {
        await FaceDetectionService.instance.predict(decodedImage, rawBytes, 0);
        await ClipImageEncoder.instance.predict(decodedImage, rawBytes, 0);
        // Tiny wait to allow the UI to update
        await Future<void>.delayed(const Duration(milliseconds: 50));
        setState(() {
          _counter += 1;
        });
        log('Inference run $_counter done');
      }
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    }
  }

  Future<void> runAsync() async {
    if (_isRunning) {
      return;
    }
    _isRunning = true;

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await NetworkClient.instance.init(packageInfo);

    await FaceDetectionService.instance.loadModel();
    await ClipImageEncoder.instance.loadModel();
    final byteData = await rootBundle.load("assets/plants.jpg");
    final imageOriginalData = byteData.buffer.asUint8List();
    final decodedImage = await decodeImageFromList(imageOriginalData);
    final rawBytes = await getRawRgbaBytes(decodedImage);

    unawaited(_runInfiniteIndexing(decodedImage, rawBytes));
  }

  @override
  Widget build(BuildContext context) {
    unawaited(runAsync());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Inference runs of both models:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
              key: ValueKey(_counter),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     unawaited(runAsync());
      //   },
      //   tooltip: 'Start running inference',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
