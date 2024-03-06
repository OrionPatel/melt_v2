import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:melt_v2/models/models.dart';
import 'package:melt_v2/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:melt_v2/logic/logic.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? _user;
int _currentIndex = 0;
Future<searchMovieResults?>? _searchFuture;

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

class search extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();
  // const search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _searchFuture = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/searchscreen.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/search.png'),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '...',
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ref
                              .read(searchProvider.notifier)
                              .searchMovies(_controller.text);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<searchMovieResults?>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                        ),
                        child: Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white))));
                  } else if (snapshot.hasData) {
                    final results = snapshot.data!;
                    return ListView.builder(
                      itemCount: results.movieResults!.length,
                      itemBuilder: (context, index) {
                        final movie = results.movieResults![index];
                        return ListTile(
                          tileColor: Colors.grey[900],
                          title: Text(
                            movie.title ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Year: ${movie.year ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            final movieId = movie.imdbId;
                            GoRouter.of(context).go('/details/$movieId');
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('Nothing to look here ;)'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 30, 0, 0),
        title: const Text(
          'MELT',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/homescreen.png'), fit: BoxFit.fill)),
        child: FutureBuilder<List<String>?>(
          future: getNowPlaying(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final movieIds = snapshot.data!;
              final likeButtonStates =
                  List.generate(movieIds.length, (index) => false);
              return MovieGrid(
                  movieIds: snapshot.data!, likeButtonStates: likeButtonStates);
            } else {
              return Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(56, 0, 0, 0).withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          offset: const Offset(0, 25),
                          blurRadius: 20),
                    ]),
                child: const Center(
                    child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.amber),
                )),
              );
            }
          },
        ),
      ),
    );
  }
}

class MovieGrid extends StatelessWidget {
  final List<String> movieIds;
  final List<bool> likeButtonStates;

  const MovieGrid(
      {Key? key, required this.movieIds, required this.likeButtonStates})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 8,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return FutureBuilder<Movie?>(
          future: getMovieByID(movieIds[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // ignore: unused_local_variable
              final movie = snapshot.data!;

              return Consumer(
                builder: (context, ref, _) {
                  return MovieTile(movie: snapshot.data!);
                },
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}

class MovieTile extends ConsumerWidget {
  final Movie movie;

  MovieTile({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(likeStateProvider);
    final isLiked = likeState.isLiked(movie.imdbId as String);

    return GridTile(
      child: GestureDetector(
        onTap: () {
          final movieId = movie.imdbId;
          GoRouter.of(context).go('/details/$movieId');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              color: const Color.fromARGB(138, 63, 63, 63).withOpacity(0.7),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    offset: const Offset(0, 25),
                    blurRadius: 20),
              ]),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(movie.imagesUrl!.first,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  Text(movie.title ?? 'Title not available',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      textAlign: TextAlign.left),
                  SizedBox(height: 4),
                  Text(movie.year ?? 'Year not available',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                  SizedBox(height: 4),
                ],
              ),
              Positioned(
                right: 5,
                top: 10,
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    ref
                        .read(likeStateProvider)
                        .toggleLike(movie.imdbId as String);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
