import 'package:decision_spinner/consts/spinner_template_definitions.dart';
import 'package:decision_spinner/storage/spinner_model.dart';

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

  // Default values
  static const String defaultSpinnerName = 'Food Slices';

  static List<Slice> defaultSlices =
      SpinnerTemplateDefinitions.whatToEatSpinner.slices;

  // Validation constraints
  static const int optionMaxLength = 100;
  static const int optionMaxCount = 50;
}
