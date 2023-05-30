import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'predictionprovider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Consumer<PredictionProvider>(
      builder: (context, provider, child) => Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/tfl_logo.png'),
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (provider.imagePath != null)
                      Image.file(File(provider.imagePath!)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(),
                              // Show model information
                              Text(
                                'Input: (shape: ${provider.inputTensor?.shape} type: ${provider.inputTensor?.type})',
                              ),
                              Text(
                                'Output: (shape: ${provider.outputTensor?.shape} type: ${provider.outputTensor?.type})',
                              ),
                              const SizedBox(height: 8),
                              // Show picked image information
                              if (provider.image != null) ...[
                                Text(
                                    'Num channels: ${provider.image?.numChannels}'),
                                Text(
                                    'Bits per channel: ${provider.image?.bitsPerChannel}'),
                                Text('Height: ${provider.image?.height}'),
                                Text('Width: ${provider.image?.width}'),
                              ],
                              const SizedBox(height: 24),
                              // Show classification result
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (provider.classification != null)
                                        ...(provider.classification!.entries
                                                .toList()
                                              ..sort(
                                                (a, b) =>
                                                    a.value.compareTo(b.value),
                                              ))
                                            .reversed
                                            .map(
                                              (e) => Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: Colors.orange
                                                    .withOpacity(0.3),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        '${e.key}: ${e.value}'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        provider.cleanResult();
                        // setState(() {});
                      },
                      child: const Text('Clean Result'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        provider.imagePath = result?.path;
                        await provider.processImage(
                            imagePath: provider.imagePath!);
                      },
                      child: const Text('Pick Image'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
