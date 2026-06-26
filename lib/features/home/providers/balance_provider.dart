import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void addBalance(int amount) {
    state += amount;
  }

  void subtractBalance(int amount) {
    if (state >= amount) {
      state -= amount;
    }
  }
}

final balanceProvider = NotifierProvider<BalanceNotifier, int>(() {
  return BalanceNotifier();
});
