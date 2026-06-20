import 'package:flutter/foundation.dart';

class WishlistStore {
  WishlistStore._();

  static final ValueNotifier<Set<int>> ids = ValueNotifier(<int>{});

  static bool contains(int id) => ids.value.contains(id);

  static void toggle(int id) {
    final next = Set<int>.from(ids.value);
    next.contains(id) ? next.remove(id) : next.add(id);
    ids.value = next;
  }
}
