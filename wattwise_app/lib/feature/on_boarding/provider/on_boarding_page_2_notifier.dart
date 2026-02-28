import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wattwise_app/feature/auth/repository/user_repository.dart';

// States and Cities of India mock data for the dropdown
const Map<String, List<String>> indiaStatesAndCities = {
  'Andhra Pradesh': [
    'Visakhapatnam',
    'Vijayawada',
    'Guntur',
    'Nellore',
    'Tirupati',
  ],
  'Arunachal Pradesh': ['Itanagar', 'Tawang', 'Ziro'],
  'Assam': ['Guwahati', 'Dibrugarh', 'Silchar', 'Jorhat'],
  'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur'],
  'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Korba'],
  'Goa': ['Panaji', 'Vasco da Gama', 'Margao', 'Mapusa'],
  'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
  'Haryana': ['Faridabad', 'Gurugram', 'Panipat', 'Ambala', 'Rohtak'],
  'Himachal Pradesh': ['Shimla', 'Manali', 'Dharamshala', 'Mandi'],
  'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro'],
  'Karnataka': ['Bengaluru', 'Mysuru', 'Hubballi', 'Mangaluru', 'Belagavi'],
  'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Kollam'],
  'Madhya Pradesh': ['Indore', 'Bhopal', 'Gwalior', 'Jabalpur', 'Ujjain'],
  'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik'],
  'Manipur': ['Imphal'],
  'Meghalaya': ['Shillong', 'Tura'],
  'Mizoram': ['Aizawl'],
  'Nagaland': ['Kohima', 'Dimapur'],
  'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri'],
  'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
  'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner'],
  'Sikkim': ['Gangtok'],
  'Tamil Nadu': [
    'Chennai',
    'Coimbatore',
    'Madurai',
    'Tiruchirappalli',
    'Salem',
  ],
  'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
  'Tripura': ['Agartala'],
  'Uttar Pradesh': [
    'Lucknow',
    'Kanpur',
    'Agra',
    'Varanasi',
    'Noida',
    'Prayagraj',
  ],
  'Uttarakhand': ['Dehradun', 'Haridwar', 'Roorkee', 'Rishikesh'],
  'West Bengal': ['Kolkata', 'Howrah', 'Siliguri', 'Durgapur', 'Asansol'],
  // Union Territories
  'Delhi': ['New Delhi', 'North Delhi', 'South Delhi'],
  'Chandigarh': ['Chandigarh'],
  'Puducherry': ['Pondicherry'],
  'Jammu and Kashmir': ['Srinagar', 'Jammu', 'Anantnag'],
};

// Available DISCOMs
const List<String> availableDiscoms = [
  'DISCOM 1',
  'DISCOM 2',
  'DISCOM 3',
  'DISCOM 4',
  'DISCOM 5',
];

class OnBoardingPage2State {
  final String? selectedState;
  final String? selectedCity;
  final String? selectedDiscom;
  final double? lat;
  final double? lng;
  final bool isLoadingLocation;
  final String? locationError;
  final bool isSaving;
  final bool hasError;

  const OnBoardingPage2State({
    this.selectedState,
    this.selectedCity,
    this.selectedDiscom,
    this.lat,
    this.lng,
    this.isLoadingLocation = false,
    this.locationError,
    this.isSaving = false,
    this.hasError = false,
  });

  OnBoardingPage2State copyWith({
    String? selectedState,
    String? selectedCity,
    String? selectedDiscom,
    double? lat,
    double? lng,
    bool? isLoadingLocation,
    String? locationError,
    bool? isSaving,
    bool? hasError,
  }) {
    return OnBoardingPage2State(
      selectedState: selectedState ?? this.selectedState,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedDiscom: selectedDiscom ?? this.selectedDiscom,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationError: locationError ?? this.locationError,
      isSaving: isSaving ?? this.isSaving,
      hasError: hasError ?? this.hasError,
    );
  }
}

class OnBoardingPage2Notifier extends StateNotifier<OnBoardingPage2State> {
  final UserRepository _repository;

  OnBoardingPage2Notifier({required UserRepository repository})
    : _repository = repository,
      super(const OnBoardingPage2State());

  List<String> get states => indiaStatesAndCities.keys.toList()..sort();

  List<String> get availableCities {
    if (state.selectedState == null) return [];
    return indiaStatesAndCities[state.selectedState] ?? [];
  }

  void updateState(String? newState) {
    state = state.copyWith(
      selectedState: newState,
      selectedCity: null, // Reset city when state changes
      locationError: null,
    );
  }

  void updateCity(String? newCity) {
    state = state.copyWith(selectedCity: newCity, locationError: null);
  }

  void updateDiscom(String? newDiscom) {
    state = state.copyWith(selectedDiscom: newDiscom);
  }

  Future<void> determineLocation() async {
    state = state.copyWith(isLoadingLocation: true, locationError: null);

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationError: 'Location services are disabled.',
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoadingLocation: false,
            locationError: 'Location permissions are denied',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationError:
              'Location permissions are permanently denied, we cannot request permissions.',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String foundState = place.administrativeArea ?? '';
          String foundCity =
              place.locality ?? place.subAdministrativeArea ?? '';

          // Basic normalisation to match our mock data
          if (foundState == 'NCT of Delhi') foundState = 'Delhi';

          // Check if state is in our top level list
          if (indiaStatesAndCities.containsKey(foundState)) {
            state = state.copyWith(
              selectedState: foundState,
              lat: position.latitude,
              lng: position.longitude,
              isLoadingLocation: false,
            );
            // Then check if the exact city is there
            if (indiaStatesAndCities[foundState]!.contains(foundCity)) {
              state = state.copyWith(selectedCity: foundCity);
            } else {
              state = state.copyWith(selectedCity: null);
            }
          } else {
            state = state.copyWith(
              isLoadingLocation: false,
              locationError:
                  'Could not match location "$foundState" to our list.',
            );
          }
        }
      } catch (e) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationError: 'Could not determine address.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        locationError: e.toString(),
      );
    }
  }

  Future<void> saveAddress() async {
    final s = state;
    if (s.selectedState == null || s.selectedCity == null) return;

    state = state.copyWith(isSaving: true, hasError: false);
    try {
      await _repository.saveAddress(
        state: s.selectedState!,
        city: s.selectedCity!,
        discom: s.selectedDiscom ?? 'Default DISCOM',
        lat: s.lat,
        lng: s.lng,
      );
      state = state.copyWith(isSaving: false);
    } catch (_) {
      state = state.copyWith(isSaving: false, hasError: true);
    }
  }
}

final onBoardingPage2Provider =
    StateNotifierProvider<OnBoardingPage2Notifier, OnBoardingPage2State>((ref) {
      final repo = ref.read(userRepositoryProvider);
      return OnBoardingPage2Notifier(repository: repo);
    });
