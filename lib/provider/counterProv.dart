
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

class Counterprov extends StateNotifier<int> {
  Counterprov() : super(0);

  void increment(int val) {
    state += val;
  }

  void decrement() {
    state--;
  }
}

final counterProv = StateNotifierProvider<Counterprov,int>((ref) {
  return Counterprov();
});
