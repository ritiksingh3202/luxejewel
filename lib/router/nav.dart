import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension SafeNavigation on BuildContext {
  /// Pops when there is history (e.g. pushed route); otherwise navigates to [fallback]
  /// so deep links and browser refreshes never hit "nothing to pop".
  void popOrGo(String fallback) => canPop() ? pop() : go(fallback);
}
