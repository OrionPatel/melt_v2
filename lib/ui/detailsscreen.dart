import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melt_v2/models/models.dart';
import 'package:melt_v2/services/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final String movieID;
  const DetailsScreen({super.key, required this.movieID});
  @override
  // ignore: library_private_types_in_public_api
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<Movie?> _movieDetails;
  bool isDescriptionExpanded = false;

  void _launchTrailer(String trailerKey) async {
    // Construct the YouTube URL using the trailer key
    String youtubeUrl = 'https://www.youtube.com/watch?v=$trailerKey';

    // Check if the URL can be launched
    if (await canLaunchUrl(youtubeUrl as Uri)) {
      // Launch the URL in a web browser
      await launchUrl(youtubeUrl as Uri);
    } else {
      throw 'Could not launch $youtubeUrl';
    }
  }

  @override
  void initState() {
    super.initState();
    _movieDetails = getMovieByID(widget.movieID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      floatingActionButton: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(255, 249, 0, 0),
        ),
        onPressed: () {
        GoRouter.of(context).go('/home');
        },
      ),
      body: FutureBuilder<Movie?>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/detailsscreen.png'))),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                        ),
                        itemCount: movie.imagesUrl!.length,
                        itemBuilder: (BuildContext context, int itemIndex,
                            int pageViewIndex) {
                          return Image.network(movie.imagesUrl![itemIndex],
                              fit: BoxFit.cover);
                        }),
                    const SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          movie.title ?? 'Title not available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          movie.tagline ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Age Rating: ${movie.rated ?? 'Rating not available'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Year: ${movie.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            'Rating: ${movie.imdbRating ?? 'Rating not available'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isDescriptionExpanded = !isDescriptionExpanded;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isDescriptionExpanded
                                  ? movie.description ??
                                      'Description not available'
                                  // ignore: prefer_interpolation_to_compose_strings
                                  : (movie.description ??
                                              'Description not available')
                                          .substring(0, 100) +
                                      '...', // Show only the first 100 characters initially
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _launchTrailer('${movie.youtubeTrailerKey}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 51, 50, 50), // Set button color to grey
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color:
                                  Colors.red, // Set YouTube icon color to red
                            ),
                            SizedBox(
                                width: 8), // Add space between icon and text
                            Text(
                              'Watch Trailer',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
