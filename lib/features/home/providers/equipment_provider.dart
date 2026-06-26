import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrailColorNotifier extends Notifier<int> {
  @override
  int build() => 0xffffff;

  void setColor(int color) => state = color;
}

class PurchasedItemsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'trail_white'}; // Default unlocked

  void unlock(String item) {
    state = {...state, item};
  }
  
  bool isUnlocked(String item) => state.contains(item);
}

class BooleanToggleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool val) => state = val;
}

final trailColorProvider = NotifierProvider<TrailColorNotifier, int>(TrailColorNotifier.new);
final purchasedItemsProvider = NotifierProvider<PurchasedItemsNotifier, Set<String>>(PurchasedItemsNotifier.new);
final epicExplosionProvider = NotifierProvider<BooleanToggleNotifier, bool>(BooleanToggleNotifier.new);
final graphicComboProvider = NotifierProvider<BooleanToggleNotifier, bool>(BooleanToggleNotifier.new);
final speedBoostProvider = NotifierProvider<BooleanToggleNotifier, bool>(BooleanToggleNotifier.new);
final longTrailProvider = NotifierProvider<BooleanToggleNotifier, bool>(BooleanToggleNotifier.new);
final glitchModeProvider = NotifierProvider<BooleanToggleNotifier, bool>(BooleanToggleNotifier.new);

class StringNotifier extends Notifier<String> {
  @override
  String build() => 'chiptune';
  void set(String val) => state = val;
}
final bgmProvider = NotifierProvider<StringNotifier, String>(StringNotifier.new);
