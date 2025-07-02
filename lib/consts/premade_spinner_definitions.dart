import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';

class PremadeSpinnerDefinitions {
  static SpinnerModel createSpinner({
    required String newId,
    required String name,
    required List<SpinnerOption> options,
    required List<Color> colors,
  }) {
    return SpinnerModel(
      newId: newId,
      name: name,
      options: options,
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
    newId: 'premade_yes_no',
    name: 'Yes or No',
    options: [
      SpinnerOption(text: 'Yes'),
      SpinnerOption(text: 'No'),
    ],
    colors: [Colors.green.shade500, Colors.red.shade500],
  );

  static SpinnerModel get whatToEatSpinner => createSpinner(
    newId: 'premade_what_to_eat',
    name: 'What to Eat',
    options: [
      'Pizza',
      'Sushi',
      'Burgers',
      'Salad',
      'Pasta',
      'Tacos',
      'Sandwich',
      'Skip Meal',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
  );

  static SpinnerModel get whatToWatchSpinner => createSpinner(
    newId: 'premade_what_to_watch',
    name: 'What to Watch',
    options: [
      'Movie',
      'TV Show',
      'Documentary',
      'YouTube',
      'Anime',
      'Sports',
      'News',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.blue.shade400, Colors.indigo.shade500],
  );

  static SpinnerModel get whereToGoSpinner => createSpinner(
    newId: 'premade_where_to_go',
    name: 'Where to Go',
    options: [
      'Coffee shop',
      'Park',
      'Mall',
      'Friend\'s place',
      'Restaurant',
      'Stay home',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.teal.shade400, Colors.teal.shade700],
  );

  static SpinnerModel get whatToDoSpinner => createSpinner(
    newId: 'premade_what_to_do',
    name: 'What to Do',
    options: [
      'Read a book',
      'Watch TV',
      'Go for a walk',
      'Play a game',
      'Clean something',
      'Take a nap',
      'Call someone',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
  );

  static SpinnerModel get workoutSpinner => createSpinner(
    newId: 'premade_workout_type',
    name: 'Workout Type',
    options: [
      'Cardio',
      'Strength training',
      'Yoga',
      'Pilates',
      'HIIT',
      'Stretching',
      'Rest day',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.red.shade300, Colors.pink.shade400],
  );

  static SpinnerModel get whoPaysSpinner => createSpinner(
    newId: 'premade_who_pays',
    name: 'Who Pays',
    options: [
      'User 1',
      'User 2',
      'User 3',
      'User 4',
      'Split',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.brown.shade300, Colors.amber.shade600],
  );

  static SpinnerModel get choreSpinner => createSpinner(
    newId: 'premade_chore',
    name: 'Chore Spinner',
    options: [
      'Dishes',
      'Laundry',
      'Vacuum',
      'Trash',
      'Clean bathroom',
      'Dust',
      'Mop floors',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.grey.shade400, Colors.blueGrey.shade600],
  );

  static SpinnerModel get breakActivitySpinner => createSpinner(
    newId: 'premade_break_activity',
    name: 'Break Activity',
    options: [
      'Stretch',
      'Drink water',
      'Walk around',
      'Deep breaths',
      'Meditate',
      'Quick tidy',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.lightBlue.shade300, Colors.cyan.shade600],
  );

  static SpinnerModel get truthOrDareSpinner => createSpinner(
    newId: 'premade_truth_or_dare',
    name: 'Truth or Dare',
    options: [
      'Truth',
      'Dare',
      'Ask someone',
      'Skip',
      'Group dare',
      'Tell a secret',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.pink.shade300, Colors.deepPurple.shade400],
  );

  static SpinnerModel get dice6Spinner => createSpinner(
    newId: 'premade_dice_6',
    name: 'Roll a Die (d6)',
    options: List.generate(6, (i) => SpinnerOption(text: '${i + 1}')),
    colors: [Colors.grey.shade300, Colors.grey.shade700],
  );

  static SpinnerModel get dice20Spinner => createSpinner(
    newId: 'premade_dice_20',
    name: 'Roll a Die (d20)',
    options: List.generate(20, (i) => SpinnerOption(text: '${i + 1}')),
    colors: [Colors.indigo.shade200, Colors.indigo.shade800],
  );

  static SpinnerModel get dateNightSpinner => createSpinner(
    newId: 'premade_date_night',
    name: 'Date Night',
    options: [
      'Movie night',
      'Cook together',
      'Go for a walk',
      'Play a game',
      'Try a new restaurant',
      'Stay in and relax',
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.red.shade200, Colors.deepOrange.shade300],
  );

  static SpinnerModel get icebreakerCasualSpinner => createSpinner(
    newId: 'premade_icebreaker_casual',
    name: 'Icebreaker: Casual',
    options: [
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
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.lightGreen.shade300, Colors.lightBlue.shade300],
  );

  static SpinnerModel get icebreakerPersonalSpinner => createSpinner(
    newId: 'premade_icebreaker_personal',
    name: 'Icebreaker: Personal',
    options: [
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
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.teal.shade300, Colors.cyan.shade400],
  );

  static SpinnerModel get icebreakerSillySpinner => createSpinner(
    newId: 'premade_icebreaker_silly',
    name: 'Icebreaker: Fun & Silly',
    options: [
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
    ].map((text) => SpinnerOption(text: text)).toList(),
    colors: [Colors.amber.shade300, Colors.purple.shade200],
  );
}
