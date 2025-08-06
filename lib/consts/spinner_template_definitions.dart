import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';

class SpinnerTemplateDefinitions {
  static SpinnerModel createSpinner({
    required String name,
    required List<Slice> slices,
    required List<Color> colors,
  }) {
    return SpinnerModel(
      name: name,
      slices: slices,
      colorThemeIndex: -1,
      backgroundColors: colors,
      customColors: colors,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      spinSound: 'pen_tick',
      spinEndSound: 'tada_end',
    );
  }

  static List<SpinnerModel> get soloDecisions => [
    yesNoSpinner,
    whatToEatSpinner,
    choreSpinner,
    breakActivitySpinner,
    dice6Spinner,
    dice20Spinner,
    workoutSpinner,
  ];

  static List<SpinnerModel> get pairDecisions => [
    whatToWatchSpinner,
    dateNightSpinner,
    whereToGoSpinner,
    truthOrDareSpinner,
    icebreakerSillySpinner,
  ];

  static List<SpinnerModel> get groupDecisions => [
    whoPaysSpinner,
    icebreakerCasualSpinner,
    icebreakerPersonalSpinner,
    whatToDoSpinner,
  ];

  static SpinnerModel get yesNoSpinner => createSpinner(
    name: 'Yes or No',
    slices: [
      Slice(text: 'Yes'),
      Slice(text: 'No'),
    ],
    colors: twoSliceColors,
  );

  static SpinnerModel get whatToEatSpinner => createSpinner(
    name: 'What to Eat',
    slices: [
      'Pizza',
      'Sushi',
      'Burgers',
      'Burrito',
      'Bacon',
      'Hot dog',
      'BBQ',
      'chicken',
      'steak',
      'Salad',
      'Pasta',
      'Tacos',
      'Sandwich',
      'Skip Meal',
    ].map((text) => Slice(text: text)).toList(),
    colors: fourSliceColors,
  );

  static SpinnerModel get whatToWatchSpinner => createSpinner(
    name: 'What to Watch',
    slices: [
      'Movie',
      'TV Show',
      'Documentary',
      'YouTube',
      'Anime',
      'Sports',
      'News',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get whereToGoSpinner => createSpinner(
    name: 'Where to Go',
    slices: [
      'Coffee shop',
      'Park',
      'Mall',
      'Friend\'s place',
      'Restaurant',
      'Stay home',
    ].map((text) => Slice(text: text)).toList(),
    colors: fourSliceColors,
  );

  static SpinnerModel get whatToDoSpinner => createSpinner(
    name: 'What to Do',
    slices: [
      'Read book',
      'Watch TV',
      'Stroll',
      'Play game',
      'Clean something',
      'Take nap',
      'Call someone',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get workoutSpinner => createSpinner(
    name: 'Workout Type',
    slices: [
      'Cardio',
      'Strength training',
      'Yoga',
      'Pilates',
      'HIIT',
      'Stretching',
      'Rest day',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get whoPaysSpinner => createSpinner(
    name: 'Who Pays',
    slices: [
      'Person 1',
      'Person 2',
      'Person 3',
      'Person 4',
      'Split',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get choreSpinner => createSpinner(
    name: 'Chore Spinner',
    slices: [
      'Dishes',
      'Laundry',
      'Vacuum',
      'Trash',
      'Clean bathroom',
      'Dust',
      'Mop floors',
    ].map((text) => Slice(text: text)).toList(),
    colors: fourSliceColors,
  );

  static SpinnerModel get breakActivitySpinner => createSpinner(
    name: 'Break Activity',
    slices: [
      'Stretch',
      'Drink water',
      'Walk around',
      'Deep breaths',
      'Meditate',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get truthOrDareSpinner => createSpinner(
    name: 'Truth or Dare',
    slices: [
      'Truth',
      'Dare',
      'Ask someone',
      'Skip',
      'Group dare',
      'Tell a secret',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get dice6Spinner => createSpinner(
    name: 'Roll a Die (d6)',
    slices: List.generate(6, (i) => Slice(text: '${i + 1}')),
    colors: [Colors.grey.shade700, Colors.blueGrey.shade700],
  );

  static SpinnerModel get dice20Spinner => createSpinner(
    name: 'Roll a Die (d20)',
    slices: List.generate(20, (i) => Slice(text: '${i + 1}')),
    colors: [Colors.indigo.shade700, Colors.blueGrey.shade600],
  );

  static SpinnerModel get dateNightSpinner => createSpinner(
    name: 'Date Night',
    slices: [
      'Movie night',
      'Cook together',
      'Take a stroll',
      'Play a game',
      'Try a new restaurant',
      'Stay in and relax',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get icebreakerCasualSpinner => createSpinner(
    name: 'Icebreaker: Casual',
    slices: [
      'What\'s your favorite movie?',
      'Coffee or tea?',
      'Morning or night person?',
      'Favorite season of the year?',
      'Do you prefer cats or dogs?',
      'What\'s your dream vacation?',
      'What\'s your favorite food?',
      'Have you ever met a celebrity?',
      'What was your first job?',
      'What\'s a hobby you enjoy?',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get icebreakerPersonalSpinner => createSpinner(
    name: 'Icebreaker: Personal',
    slices: [
      'What\'s a goal you\'re working on?',
      'What\'s a book that changed you?',
      'What motivates you?',
      'If you could live anywhere, where?',
      'What\'s your proudest achievement?',
      'What\'s a hidden talent you have?',
      'Who inspires you?',
      'What\'s a big risk you\'ve taken?',
      'What would you do with a million dollars?',
      'What do you value most in a friendship?',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get icebreakerSillySpinner => createSpinner(
    name: 'Icebreaker: Fun & Silly',
    slices: [
      'Would you rather fight 1 horse-sized duck or 100 duck-sized horses?',
      'What\'s the weirdest food you\'ve eaten?',
      'If animals could talk, which would be the rudest?',
      'What\'s your zombie apocalypse plan?',
      'If you were a fruit, what would you be?',
      'What\'s your guilty pleasure song?',
      'Aliens land — what\'s your first move?',
      'What would your theme song be?',
      'Which superpower would you want?',
      'If you had to eat one meal forever?',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );
}

final List<Color> twoSliceColors = [
  Color(0xFF007ACC), // Bright blue
  Color(0xFFFFB400), // Warm amber
];

final List<Color> threeSliceColors = [
  Color(0xFFFF5C5C), // Red-rose
  Color(0xFF5CFF5C), // Spring green
  Color(0xFF5C5CFF), // Soft blue
];

final List<Color> fourSliceColors = [
  Color(0xFFFF6B6B), // Coral red
  Color(0xFFFFD93D), // Golden yellow
  Color(0xFF6BCB77), // Medium green
  Color(0xFF4D96FF), // Sky blue
];

final List<Color> fiveSliceColors = [
  Color(0xFF007ACC), // Coral red
  Color(0xFFFF5733), // Golden yellow
  Color(0xFF28A745), // Medium green
  Color(0xFFFFC107), // Sky blue
  Color(0xFF6F42C1), // Purple
];

final List<Color> sevenSliceColors = [
  Color(0xFFFF6B6B), // Coral red
  Color(0xFFFFD93D), // Golden yellow
  Color(0xFF6BCB77), // Medium green
  Color(0xFF4D96FF), // Sky blue
  Color(0xFF845EC2), // Purple
  Color(0xFFFF9671), // Orange
  Color(0xFF00C9A7), // Aqua teal
];
