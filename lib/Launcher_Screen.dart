
import 'package:erthquake_app/pages/home_page.dart';
import 'package:flutter/material.dart';

class LauncherScreen extends StatefulWidget {
  static const String routeName = "/";
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3),(){
        Navigator.pushReplacementNamed(context, HomePage.routeName);

    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Earthquke App" ,style: Theme.of(context).textTheme.titleLarge,)
            ],
          ),
        ),
      ),
    );
  }
}
