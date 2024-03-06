import 'package:flutter/material.dart';
import 'package:melt_v2/models/models.dart';
import 'package:melt_v2/services/services.dart';

import 'package:sign_in_button/sign_in_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';




final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});



class LikeState extends ChangeNotifier {
  Map<String, bool> _likes = {};

  bool isLiked(String movieId) => _likes[movieId] ?? false;

  void toggleLike(String movieId) {
    _likes[movieId] = !isLiked(movieId);
    notifyListeners();
  }
}

class SearchNotifier extends StateNotifier<Future<searchMovieResults?>?> {
  SearchNotifier() : super(null);

  void searchMovies(String text) {
    state = getMovieByTitle(text);
  }
}

final likeStateProvider =
    ChangeNotifierProvider<LikeState>((ref) => LikeState());
final searchProvider =
    StateNotifierProvider<SearchNotifier, Future<searchMovieResults?>?>(
        (ref) => SearchNotifier());
final currentIndexProvider = StateProvider<int>((ref) => 0);
