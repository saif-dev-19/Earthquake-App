import 'package:erthquake_app/Launcher_Screen.dart';
import 'package:erthquake_app/pages/home_page.dart';
import 'package:erthquake_app/providers/app_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      initialRoute: LauncherScreen.routeName,
      routes: {
        LauncherScreen.routeName : (_) => const LauncherScreen(),
        HomePage.routeName : (_) => const HomePage(),
      }
    );
  }
}

