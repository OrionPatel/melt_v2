import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melt_v2/firebase_options.dart';
import 'ui/detailsscreen.dart';
import 'ui/homescreen.dart';
import 'ui/splashscreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: MyAppRoutes()._router,
    );
  }
}

class MyAppRoutes {
  final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    errorPageBuilder: (BuildContext context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text(
            'Error ${state.error}',
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
          path: '/details/:id',
          builder: (BuildContext context, state) {
            final movieId = state.pathParameters['id'];
            return DetailsScreen(movieID: movieId!);
          },
        )
    ],
  );
}
