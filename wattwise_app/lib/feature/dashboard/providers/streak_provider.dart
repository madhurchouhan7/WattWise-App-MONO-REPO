import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/auth/providers/auth_provider.dart';
import 'package:wattwise_app/feature/auth/repository/user_repository.dart';

/// Tracks if a check-in was performed in the current session (optimistic UI)
final optimisticCheckInProvider = StateProvider<bool>((ref) => false);

/// Provides the current streak, accounting for broken streaks.
final streakProvider = Provider<int>((ref) {
  final userAsync = ref.watch(authStateProvider);
  final isOptimistic = ref.watch(optimisticCheckInProvider);
  final user = userAsync.valueOrNull;
  
  if (user == null) return 0;
  
  int currentStreak = user.streak;
  DateTime? last = user.lastCheckIn;

  // If we just checked in optimistically, simulate the new state
  if (isOptimistic) {
    if (last == null) {
      return 1;
    }
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    
    if (difference == 0) return currentStreak; // already counted
    if (difference == 1) return currentStreak + 1;
    return 1; // broken then restarted
  }

  if (last == null) return 0;
  
  final now = DateTime.now();
  
  // Calculate difference in days (ignoring time)
  final difference = DateTime(now.year, now.month, now.day)
      .difference(DateTime(last.year, last.month, last.day))
      .inDays;
      
  if (difference > 1) {
    // Streak broken (missed at least one day)
    return 0;
  }
  
  // ignore: unnecessary_null_comparison
  return currentStreak ?? 0;
});

/// Notifier to handle check-in logic
class StreakNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepository _repo;
  final Ref _ref;

  StreakNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> checkIn() async {
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final now = DateTime.now();
    final last = user.lastCheckIn;
    
    int newStreak = user.streak;
    
    if (last == null) {
      newStreak = 1;
    } else {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
          
      if (difference == 0) {
        // Already checked in today
        return;
      } else if (difference == 1) {
        newStreak++;
      } else {
        // Streak was broken, start again
        newStreak = 1;
      }
    }

    // Set optimistic state immediately
    _ref.read(optimisticCheckInProvider.notifier).state = true;
    
    state = const AsyncValue.loading();
    try {
      await _repo.updateStreak(newStreak, now);
      // Refresh the user state
      _ref.invalidate(authStateProvider);
      // Clear optimistic state once real data is in (it will trigger re-fetch)
      _ref.read(optimisticCheckInProvider.notifier).state = false;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _ref.read(optimisticCheckInProvider.notifier).state = false;
      state = AsyncValue.error(e, st);
    }
  }
}

final streakNotifierProvider = StateNotifierProvider<StreakNotifier, AsyncValue<void>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return StreakNotifier(repo, ref);
});
