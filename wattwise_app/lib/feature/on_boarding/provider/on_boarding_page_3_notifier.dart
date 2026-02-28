import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wattwise_app/feature/auth/repository/user_repository.dart';

class OnBoardingPage3State {
  final int peopleCount;
  final String? selectedFamilyType;
  final String? selectedHouseType;

  const OnBoardingPage3State({
    this.peopleCount = 2,
    this.selectedFamilyType,
    this.selectedHouseType,
  });

  OnBoardingPage3State copyWith({
    int? peopleCount,
    String? selectedFamilyType,
    String? selectedHouseType,
  }) {
    return OnBoardingPage3State(
      peopleCount: peopleCount ?? this.peopleCount,
      selectedFamilyType: selectedFamilyType ?? this.selectedFamilyType,
      selectedHouseType: selectedHouseType ?? this.selectedHouseType,
    );
  }
}

class OnBoardingPage3Notifier extends StateNotifier<OnBoardingPage3State> {
  final UserRepository _repository;

  OnBoardingPage3Notifier({required UserRepository repository})
    : _repository = repository,
      super(const OnBoardingPage3State());

  void incrementPeople() {
    state = state.copyWith(peopleCount: state.peopleCount + 1);
  }

  void decrementPeople() {
    if (state.peopleCount > 1) {
      state = state.copyWith(peopleCount: state.peopleCount - 1);
    }
  }

  void updateFamilyType(String? familyType) {
    state = state.copyWith(selectedFamilyType: familyType);
  }

  void updateHouseType(String? houseType) {
    state = state.copyWith(selectedHouseType: houseType);
  }

  Future<void> saveDetails() async {
    await _repository.saveHouseholdDetails(
      peopleCount: state.peopleCount,
      familyType: state.selectedFamilyType,
      houseType: state.selectedHouseType,
    );
  }
}

final onBoardingPage3Provider =
    StateNotifierProvider<OnBoardingPage3Notifier, OnBoardingPage3State>((ref) {
      final repo = ref.read(userRepositoryProvider);
      return OnBoardingPage3Notifier(repository: repo);
    });
