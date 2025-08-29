class StorageConstants {
  // Spinner related keys
  static const String spinnersKey = 'decision_spinner_spinners';
  static const String activeSpinnerKey = 'decision_spinner_active_spinner';

  // Color related keys
  static const String savedGradientColorsKey =
      'decision_spinner_saved_gradient_colors';
  static const String savedSolidColorsKey =
      'decision_spinner_saved_solid_colors';
  static const String useGradientKey = 'decision_spinner_use_gradient';
  static const String colorThemeKey = 'decision_spinner_color_theme';

  // Onboarding
  static const String selectedCategoriesKey = 'selected_categories';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String onboardingCompletedTimestampKey =
      'onboarding_completed_timestamp';

  // Review
  static const String reviewShownKey = 'review_shown';
  static const String reviewPostponedKey = 'review_postponed_timestamp';

  // Validation constraints
  static const int optionMaxLength = 100;
  static const int optionMaxCount = 50;
}
