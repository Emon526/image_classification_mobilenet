import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PredictionProvider extends ChangeNotifier {
  PredictionProvider() {
    loadModel();
    loadLabels();
  }

  static const modelPath = 'assets/working.tflite';
  static const labelsPath = 'assets/labels.txt';

  // static const modelPath = 'assets/mobilenet/mobilenet_v1_1.0_224_quant.tflite';
  // static const labelsPath = 'assets/mobilenet/labels.txt';
  late final Interpreter interpreter;
  Tensor? inputTensor;
  Tensor? outputTensor;
  late final List<String> labels;
  Map<String, int>? classification;
  img.Image? image;
  String? imagePath;

  Future<void> loadModel() async {
    final options = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    // Use GPU Delegate
    // doesn't work on emulator
    // if (Platform.isAndroid) {
    //   options.addDelegate(GpuDelegateV2());
    // }

    // Use Metal Delegate
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get tensor input shape [1, 224, 224, 3]
    inputTensor = interpreter.getInputTensors().first;
    // Get tensor output shape [1, 1001]
    outputTensor = interpreter.getOutputTensors().first;

    log('Interpreter loaded successfully');
    notifyListeners();
  }

  Future<void> loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
    log('label loaded successfully');
  }

  Future<void> runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    // Set tensor input [1, 224, 224, 3]
    final input = [imageMatrix];
    // Set tensor output [1, 1001]
    final output = [List<int>.filled(1001, 0)];

    // Run inference
    interpreter.run(input, output);

    // Get first output tensor
    final result = output.first;

    // Set classification map {label: points}
    classification = <String, int>{};

    for (var i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        // Set label: points
        classification![labels[i]] = result[i];
      }
    }
    log('run successful');
    notifyListeners();
  }

  Future<void> processImage({required String imagePath}) async {
    final imageData = File(imagePath).readAsBytesSync();

    // Decode image using package:image/image.dart (https://pub.dev/image)
    image = img.decodeImage(imageData);

    // Resize image for model input (Mobilenet use [224, 224])
    final imageInput = img.copyResize(
      image!,
      width: 224,
      height: 224,
    );

    // Get image matrix representation [224, 224, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    // Run model inference
    log('image processed successfully');
    runInference(imageMatrix);
  }

  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    notifyListeners();
  }
}
