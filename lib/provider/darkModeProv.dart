
// Your existing Dark Mode Provider (simplified)
import 'package:flutter_riverpod/legacy.dart';

class DarkModeProv extends StateNotifier<bool> {
  DarkModeProv() : super(true);
  void toggle() => state = !state;
}

final darkmode = StateNotifierProvider<DarkModeProv, bool>((ref) => DarkModeProv());