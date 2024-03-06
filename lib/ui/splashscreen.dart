import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void pushReplacement(BuildContext context) {
    context.go('/home', extra: 'Data from splash screen');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
        const Duration(milliseconds: 300), () => pushReplacement(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splashscreen.png'),
          ),
        ),
        child: Center(child: Column(
          children: [
            SizedBox(height: 500),
            CircularProgressIndicator(color: Colors.redAccent[700]),
          ],
        )),
      ),
    );
  }
}
