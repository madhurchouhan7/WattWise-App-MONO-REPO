import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the user has added at least one bill.
/// In production this would be a FutureProvider that fetches from the backend.
/// For now it is a simple StateProvider so the rest of the UI can react to it.
final hasBillsProvider = StateProvider<bool>((ref) => false);
