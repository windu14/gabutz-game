import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoreNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void updateScore(int newScore) {
    if (newScore > state) {
      state = newScore;
    }
  }
}

final scoreProvider = NotifierProvider<ScoreNotifier, int>(() => ScoreNotifier());

class CoinsNotifier extends Notifier<int> {
  @override
  int build() => 3000;
  
  void addCoins(int amount) {
    state += amount;
  }
}

final coinsProvider = NotifierProvider<CoinsNotifier, int>(() => CoinsNotifier());
