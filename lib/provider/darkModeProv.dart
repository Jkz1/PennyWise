
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

class Counterprov extends StateNotifier<bool> {
  Counterprov() : super(true);

  void toggle() {
    state = !state;
  }
}

final counterProv = StateNotifierProvider<Counterprov,bool>((ref) {
  return Counterprov();
});
