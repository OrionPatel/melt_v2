import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:melt_v2/models/models.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:melt_v2/logic/logic.dart';
import 'ui_components.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? _user;
int _currentIndex = 0;
Future<searchMovieResults?>? _searchFuture;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(authStateProvider);
    //final User? user = ref.watch(authStateProvider.stream);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          opacity: 0.5,
          image: AssetImage(
            'assets/splashscreen.png',
          ),
        ),
      ),
      child: userAsyncValue.when(
        data: (user) =>
            user != null ? HomePage(user: user) : _googleSignInButton(),
        loading: () => CircularProgressIndicator(),
        error: (_, __) => Text("Error"),
      ),
      // child: _user != null ? HomePage() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 500),
          SizedBox(
            height: 50,
            child: SignInButton(
              Buttons.google,
              text: 'Sign up with Google',
              onPressed: () {
                _handleGoogleSignIn();
                // _auth.authStateChanges().listen((event) {
                //   _user = event;

                // });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(_googleAuthProvider);
    } catch (e) {
      print('Error: $e');
    }
  }
}

class HomePage extends ConsumerWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final _searchFuture = ref.watch(searchProvider);

    List<Widget> _pages = [
      home(),
      search(),
      _User(user),
    ];
    final _currentIndex = ref.watch(currentIndexProvider);
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
        itemPadding: EdgeInsets.all(10),
        itemShape: const StadiumBorder(),
        backgroundColor: Color.fromARGB(255, 197, 52, 42),
        currentIndex: _currentIndex,
        onTap: (int index) {
          ref.read(currentIndexProvider.notifier).state = index;
        },
        items: [
          SalomonBottomBarItem(
            selectedColor: const Color.fromARGB(255, 246, 246, 246),
            unselectedColor: const Color.fromARGB(255, 0, 0, 0),
            icon: const Icon(Icons.play_arrow_rounded),
            title: const Text('Now Playing'),
          ),
          SalomonBottomBarItem(
            selectedColor: const Color.fromARGB(255, 250, 250, 250),
            unselectedColor: Color.fromARGB(255, 209, 177, 72),
            icon: const Icon(Icons.search),
            title: const Text('Search'),
          ),
          SalomonBottomBarItem(
            selectedColor: const Color.fromARGB(255, 249, 249, 249),
            unselectedColor: Color.fromARGB(255, 255, 103, 154),
            icon: const Icon(Icons.person_2),
            title: const Text('Profile'),
          ),
        ],
      ),
      body: _pages[_currentIndex],
    );
  }
}

Widget _User(User? user) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/user.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'MELT',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 251, 25, 25),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                MaterialButton(
                  color: Color.fromARGB(255, 228, 53, 53),
                  child: const Text('Sign Out'),
                  onPressed: () {
                    _auth.signOut();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 60,
                    child: Image.network(
                      user?.photoURL ?? '',
                      errorBuilder: (context, error, stackTrace) =>
                          Text('image not found'),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Email: ${user?.email ?? 'Email not found'}',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            // child:  Text(
            //     user?.email ?? 'No name',
            //     style: TextStyle(color: Colors.amberAccent),
            //     ),
          ),
        ],
      ),
    ),
  );
}
