import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'predictionprovider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PredictionProvider(),
        ),
      ],
      builder: (context, child) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
          ),
        ),
        home: const Home(),
      ),
    );
  }
}
