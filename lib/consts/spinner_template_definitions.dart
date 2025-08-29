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

  // Teaching & Classroom - Core teacher tools, still usable by general audiences
  static List<SpinnerModel> get teachingAndClassroom => [
    breakActivityGeneralSpinner,
    studyTopicSpinner,
    creativePromptSpinner,
    activityForKidsSpinner,
    groupActivitySpinner,
    icebreakerCasualSpinner,
    mindfulnessActivitySpinner,
    whatToLearnSpinner,
    homeworkTaskSpinner,
    dice6Spinner,
    dice20Spinner,
  ];

  // Life & Home - Daily living and household decisions
  static List<SpinnerModel> get lifeAndHome => [
    whatToEatSpinner,
    whereToGoGeneralSpinner,
    whatToDoSpinner,
    whatToDoTodaySpinner,
    whatToCleanSpinner,
    chorePickerSpinner,
    homeProjectSpinner,
    declutterTaskSpinner,
    whatToWearSpinner,
    lunchboxIdeaSpinner,
    subscriptionReviewSpinner,
    budgetingTaskSpinner,
    yesNoSpinner,
  ];

  // Health & Self-Care - Personal wellness and physical activity
  static List<SpinnerModel> get healthAndSelfCare => [
    workoutSpinner,
    mindfulnessActivitySpinner,
    morningRoutineSpinner,
    selfCareIdeaSpinner,
    healthyHabitSpinner,
  ];

  // Fun & Social - Entertainment and group fun
  static List<SpinnerModel> get funAndSocial => [
    groupActivitySpinner,
    dateNightIdeaSpinner,
    familyNightSpinner,
    icebreakerCasualSpinner,
    whatToWatchGeneralSpinner,
    gameToPlaySpinner,
    whoToCallSpinner,
    whatToListenToSpinner,
    whoPaysSpinner,
  ];

  // Productivity & Work - Focus, learning, and skill-building for adults
  static List<SpinnerModel> get productivityAndWork => [
    focusTaskSpinner,
    whatToLearnSpinner,
    skillToPracticeSpinner,
    creativePromptSpinner,
  ];

  // Games & Challenges - Gamification, tabletop, and light competition
  static List<SpinnerModel> get gamesAndChallenges => [
    dice6Spinner,
    dice20Spinner,
    randomChallengeSpinner,
  ];

  static SpinnerModel get yesNoSpinner => createSpinner(
    name: 'Yes or No',
    slices: [
      Slice(text: 'Yes ✅'),
      Slice(text: 'No ❌'),
    ],
    colors: twoSliceColors,
  );

  static SpinnerModel get whatToEatSpinner => createSpinner(
    name: 'What to Eat',
    slices: [
      'Pizza 🍕',
      'Sushi 🍣',
      'Burgers 🍔',
      'Burrito 🌯',
      'Bacon 🥓',
      'Hot dog 🌭',
      'BBQ 🍖',
      'chicken 🍗',
      'steak 🥩',
      'Salad 🥗',
      'Pasta 🍝',
      'Tacos 🌮',
      'Sandwich 🥪',
      'Skip Meal 🚫',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whereToGoSpinner => createSpinner(
    name: 'Where to Go',
    slices: [
      'Coffee shop ☕',
      'Park 🌳',
      'Mall 🛍️',
      'Friend\'s place 🏠',
      'Restaurant 🍴',
      'Stay home 🛋️',
    ].map((text) => Slice(text: text)).toList(),
    colors: fourSliceColors,
  );

  static SpinnerModel get whatToDoSpinner => createSpinner(
    name: 'What to Do',
    slices: [
      'Read book 📖',
      'Watch TV 📺',
      'Stroll 🚶',
      'Play game 🎮',
      'Clean something 🧹',
      'Take nap 😴',
      'Call someone 📞',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get workoutSpinner => createSpinner(
    name: 'Workout Type',
    slices: [
      'Cardio 🏃',
      'Strength training 🏋️',
      'Yoga 🧘',
      'Pilates 🤸',
      'Core workout 💪',
      'HIIT 🏋️‍♂️',
      'Stretching 🤸‍♀️',
      'Rest day 🛌',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );

  static SpinnerModel get whoPaysSpinner => createSpinner(
    name: 'Who Pays',
    slices: [
      'Person 1 🧍',
      'Person 2 🧍‍♀️',
      'Person 3 🧍‍♂️',
      'Person 4 🧍‍♂️',
      'Split 💸',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get breakActivitySpinner => createSpinner(
    name: 'Break Activity',
    slices: [
      'Stretch 🧘',
      'Drink water 💧',
      'Walk around 🚶',
      'Deep breaths 😌',
      'Meditate 🧘‍♂️',
    ].map((text) => Slice(text: text)).toList(),
    colors: threeSliceColors,
  );
  static SpinnerModel get dice6Spinner => createSpinner(
    name: 'Roll a Die (d6)',
    slices: List.generate(6, (i) => Slice(text: '${i + 1} 🎲')),
    colors: [Colors.grey.shade700, Colors.blueGrey.shade700],
  );

  static SpinnerModel get dice20Spinner => createSpinner(
    name: 'Roll a Die (d20)',
    slices: List.generate(20, (i) => Slice(text: '${i + 1} 🎲')),
    colors: [Colors.indigo.shade700, Colors.blueGrey.shade600],
  );

  static SpinnerModel get icebreakerCasualSpinner => createSpinner(
    name: 'Icebreaker',
    slices: [
      'What\'s your favorite movie? 🎥',
      'Coffee or tea? ☕',
      'Morning or night person? 🌅',
      'Favorite season of the year? 🍂',
      'Do you prefer cats or dogs? 🐱🐶',
      'What\'s your dream vacation? ✈️',
      'What\'s your favorite food? 🍔',
      'Have you ever met a celebrity? 🌟',
      'What was your first job? 💼',
      'What\'s a hobby you enjoy? 🎨',
      'What\'s a goal you\'re working on? 🎯',
      'What\'s a book that changed you? 📚',
      'What motivates you? 🚀',
      'If you could live anywhere, where? 🏝️',
      'What\'s your proudest achievement? 🏆',
      'What\'s a hidden talent you have? 🎭',
      'Who inspires you? 🌟',
      'What\'s a big risk you\'ve taken? 🎲',
      'What would you do with a million dollars? 💵',
      'What do you value most in a friendship? 🤝',
      'Would you rather fight 1 horse-sized duck or 100 duck-sized horses? 🦆🐴',
      'What\'s the weirdest food you\'ve eaten? 🍣',
      'If animals could talk, which would be the rudest? 🐒',
      'What\'s your zombie apocalypse plan? 🧟',
      'If you were a fruit, what would you be? 🍎',
      'What\'s your guilty pleasure song? 🎵',
      'Aliens land — what\'s your first move? 👽',
      'What would your theme song be? 🎶',
      'Which superpower would you want? 🦸',
      'If you had to eat one meal forever? 🍽️',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  // Life & Home Spinners
  static SpinnerModel get whatToWearSpinner => createSpinner(
    name: 'What to Wear',
    slices: [
      'Casual 👕',
      'Comfy/lounge 🩳',
      'Business casual 👔',
      'Sporty 🏃‍♂️',
      'All black 🖤',
      'Bright colors 🌈',
      'Weather-based 🌦️',
      'Dress/skirt 👗',
      'Layers 🧥',
      'Whatever\'s clean 🧺',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whatToDoTodaySpinner => createSpinner(
    name: 'What to Do Today',
    slices: [
      'Run errands 🛒',
      'Clean something 🧹',
      'Start new project 🛠️',
      'Watch movie 🎥',
      'Go for walk 🚶‍♀️',
      'Learn something 📚',
      'Call/text someone 📞',
      'Declutter area 🗑️',
      'Journal 🖊️',
      'Cook/bake 🍳',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whereToGoGeneralSpinner => createSpinner(
    name: 'Where to Go',
    slices: [
      'Local café ☕',
      'Park 🌳',
      'Grocery store 🛍️',
      'Friend\'s place 🏠',
      'Library/bookstore 📖',
      'Stay home 🛋️',
      'Random walk 🚶',
      'Gym 🏋️',
      'Drive around 🚗',
      'Somewhere new 🌍',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whatToCleanSpinner => createSpinner(
    name: 'What to Clean',
    slices: [
      'Kitchen counters 🍽️',
      'Bathroom 🛁',
      'Floors 🧹',
      'Fridge/pantry 🧊',
      'Desk/workspace 🖥️',
      'Windows/mirrors 🪟',
      'Laundry 🧺',
      'Entryway 🚪',
      'Trash/recycling 🗑️',
      'Something bugging you 🐛',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get declutterTaskSpinner => createSpinner(
    name: 'Declutter Task',
    slices: [
      'One drawer 🗄️',
      'Old clothes 👕',
      'Digital photos 🖼️',
      'Email inbox 📧',
      'Phone apps 📱',
      'Bookshelf 📚',
      'Kitchen utensils 🍴',
      'Junk box 📦',
      'Wallet/purse 👛',
      'Papers/receipts 📄',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get roomToTidySpinner => createSpinner(
    name: 'Room to Tidy',
    slices: [
      'Bedroom 🛏️',
      'Living room 🛋️',
      'Kitchen 🍴',
      'Bathroom 🛁',
      'Entryway 🚪',
      'Office/workspace 🖥️',
      'Closet 👗',
      'Garage/storage 🛠️',
      'Kids\' room 🧸',
      'Car interior 🚗',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get chorePickerSpinner => createSpinner(
    name: 'Chore Picker',
    slices: [
      'Laundry 🧺',
      'Dishes 🍽️',
      'Clean toilet 🚽',
      'Take out trash 🗑️',
      'Sweep/vacuum 🧹',
      'Wipe counters 🧽',
      'Change sheets 🛏️',
      'Clean mirrors 🪞',
      'Water plants 🌱',
      'Mop floors 🧼',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get homeProjectSpinner => createSpinner(
    name: 'Home Project to Start',
    slices: [
      'Organize closet 👗',
      'Declutter storage 📦',
      'Hang art/photos 🖼️',
      'Rearrange furniture 🛋️',
      'Deep clean room 🧹',
      'Label containers 🏷️',
      'Touch up paint 🎨',
      'Organize tools 🛠️',
      'Sort donations 🎁',
      'Start garden care 🌱',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );
  static SpinnerModel get subscriptionReviewSpinner => createSpinner(
    name: 'Subscription to Review',
    slices: [
      'Streaming services 📺',
      'Music apps 🎵',
      'Cloud storage ☁️',
      'News/magazines 📰',
      'Fitness/gym 🏋️',
      'Meal delivery 🍱',
      'Online courses 💻',
      'Gaming services 🎮',
      'Productivity tools 🛠️',
      'Trial subscriptions 🆓',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get budgetingTaskSpinner => createSpinner(
    name: 'Budgeting Task',
    slices: [
      'Check balance 💰',
      'Track expenses 📊',
      'Categorize spending 🗂️',
      'Plan meals 🍴',
      'Review subscriptions 📋',
      'Set savings goal 🎯',
      'Pay upcoming bill 🧾',
      'Review past budget 📜',
      'Update tracker 📈',
      'Check statements 🏦',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get morningRoutineSpinner => createSpinner(
    name: 'Morning Routine Step',
    slices: [
      'Drink water',
      'Stretch/move',
      'Shower',
      'Eat breakfast',
      'Make bed',
      'Plan day',
      'Journal',
      'Meditate 5min',
      'No phone 30min',
      'Short walk',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get lunchboxIdeaSpinner => createSpinner(
    name: 'Lunchbox Idea',
    slices: [
      'Sandwich + fruit 🥪🍎',
      'Wrap + veggies 🌯🥦',
      'Leftovers 🍲',
      'Salad + roll 🥗🥖',
      'Pasta salad 🍝',
      'Rice + protein 🍚🍗',
      'Bento box 🍱',
      'Cheese + crackers 🧀🍘',
      'Hummus + pita 🥙',
      'DIY lunchables 🧺',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get selfCareIdeaSpinner => createSpinner(
    name: 'Self-Care Idea',
    slices: [
      'Long shower/bath 🛁',
      'Listen to music 🎵',
      'Comfort show/movie 🎥',
      'Journal 10min 🖊️',
      'Screen break 📵',
      'Go outside 🌳',
      'Skincare routine 🧴',
      'Favorite drink ☕',
      'Meditate/breathe 🧘',
      'Do nothing 15min 🛋️',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get healthyHabitSpinner => createSpinner(
    name: 'Healthy Habit to Focus On',
    slices: [
      'Drink more water 💧',
      'Eat veggies 🥦',
      'Sleep earlier 🛌',
      'Stretch daily 🤸',
      'Limit screen time 📵',
      'Walk after meals 🚶',
      'Cook at home 🍳',
      'Avoid sugar 🍬',
      'Track mood 📊',
      'Good posture 🧍',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get mindfulnessActivitySpinner => createSpinner(
    name: 'Mindfulness Activity',
    slices: [
      '5min meditation 🧘',
      'Body scan 🩻',
      'Free journaling 🖊️',
      'Mindful breathing 🌬️',
      'Notice 5 things 👀',
      'Gratitude list 🙏',
      'Do one thing slowly 🐢',
      'Sit in silence 🤫',
      'Guided meditation 🎧',
      'Observe thoughts 💭',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get breakActivityGeneralSpinner => createSpinner(
    name: 'Break Activity',
    slices: [
      'Stretch/walk 🚶',
      'Get water 💧',
      'Listen to song 🎵',
      'Look outside 🌤️',
      'Quick tidy 🧹',
      'Step outside 🚪',
      'Pet/animal photos 🐾',
      'Mindful snack 🍎',
      '10 squats/jumps 🤸',
      'Deep breaths 1min 😌',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get focusTaskSpinner => createSpinner(
    name: 'Focus',
    slices: [
      'Do nothing for 3 minutes 🛋️',
      'Name one distraction, remove it 🚫',
      'List steps to do the task 📝',
      'Define your intention in one sentence 🎯',
      'Box breathing 🌬️',
      'Mind dump 🧠',
      'Light snack 🍎',
      '10 jumping jacks/squats 🤸',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get randomChallengeSpinner => createSpinner(
    name: 'Random Challenge',
    slices: [
      'No social media 2hr 📵',
      'Compliment someone 😊',
      'Photo something nice 📸',
      'Write 3 wins today 🏆',
      'Check email 2x only 📧',
      'Cook from scratch 🍳',
      '2min cold shower 🚿',
      'Clean 10min 🧹',
      'Walk without phone 🚶',
      'Say no to something ❌',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whatToLearnSpinner => createSpinner(
    name: 'What to Learn Today',
    slices: [
      'New word/phrase 🗣️',
      'Educational video 🎥',
      'Random article 📄',
      'Practice language 🌍',
      'Coding challenge 💻',
      'New recipe 🍲',
      'Historical event 🏛️',
      'Scientific concept 🔬',
      'Creative tutorial 🎨',
      'Learning resource 📚',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get skillToPracticeSpinner => createSpinner(
    name: 'Skill to Practice',
    slices: [
      'Typing ⌨️',
      'Drawing 🎨',
      'Cooking 🍳',
      'Instrument 🎻',
      'Public speaking 🎤',
      'Mental math 🧮',
      'Writing ✍️',
      'Photo/video editing 🎥',
      'Coding 💻',
      'Time management ⏳',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get creativePromptSpinner => createSpinner(
    name: 'Creative Prompt',
    slices: [
      'Draw current mood 🎭',
      'One paragraph story 📜',
      'Create with circles 🔵',
      'Useless product idea 🛠️',
      'Redesign book cover 📘',
      'Describe unseen place 🌌',
      'Doodle no lift ✏️',
      'No context dialogue 💬',
      'Object to character 🪑➡️👤',
      'Three color scene 🎨',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get studyTopicSpinner => createSpinner(
    name: 'Study Topic',
    slices: [
      'History 🏺',
      'Math ➗',
      'Science 🔬',
      'Language learning 🗣️',
      'Geography 🌍',
      'Economics or finance 💵',
      'Psychology 🧠',
      'Art or design 🎨',
      'Technology 🖥️',
      'Philosophy 📖',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  // Fun & Social Spinners
  static SpinnerModel get whatToWatchGeneralSpinner => createSpinner(
    name: 'What to Watch',
    slices: [
      'Comfort movie 🎥',
      'Random documentary 📽️',
      'New series episode 📺',
      'YouTube video ▶️',
      'Foreign film 🌍',
      'Classic unseen 🎞️',
      'Comedy special 😂',
      'Nature doc 🌿',
      'Guilty pleasure show 🍿',
      'Watchlist film 🎬',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whatToListenToSpinner => createSpinner(
    name: 'What to Listen To',
    slices: [
      'Podcast episode 🎙️',
      'Full album 💿',
      'New music genre 🎶',
      'Movie soundtrack 🎵',
      'Ambient sounds 🌌',
      'Live recording 🎤',
      'Friend\'s playlist 🎧',
      'Lo-fi beats 🎼',
      'Audiobook sample 📚',
      'Music decade 📀',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get gameToPlaySpinner => createSpinner(
    name: 'Game to Play',
    slices: [
      'Mobile puzzle 📱',
      'Word game 🔤',
      'Card game 🃏',
      'New video game 🎮',
      'Board game 🎲',
      'Chess/checkers ♟️',
      'Party game 🎉',
      'Co-op multiplayer 🤝',
      'Trivia/quiz ❓',
      'Old favorite 🕹️',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get whoToCallSpinner => createSpinner(
    name: 'Who to Call/Text',
    slices: [
      'Close friend 🤗',
      'Family member 👨‍👩‍👧‍👦',
      'Coworker 💼',
      'Haven\'t seen lately 🕒',
      'Old classmate 🎓',
      'Someone you miss 💔',
      'Person to thank 🙏',
      'Neighbor/local friend 🏡',
      'Funny friend 😂',
      'Group chat 💬',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get dateNightIdeaSpinner => createSpinner(
    name: 'Date Night Idea',
    slices: [
      'Cook together 🍳',
      'Watch movie/show 🎥',
      'Walk/drive 🚶‍♂️',
      'Board/card game 🎲',
      'New restaurant 🍴',
      'Taste test 🍷',
      'Stargazing 🌌',
      'DIY spa night 🛀',
      'Make playlist 🎶',
      'Local event 🎭',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get activityForKidsSpinner => createSpinner(
    name: 'Activity for Kids',
    slices: [
      'Drawing/coloring 🎨',
      'Build blocks/LEGO 🧱',
      'Make fort 🏰',
      'Scavenger hunt 🔍',
      'Dance party 💃',
      'Simple baking 🍪',
      'Water play 💦',
      'Story time 📖',
      'Obstacle course 🏃',
      'Playdough/slime 🧼',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get groupActivitySpinner => createSpinner(
    name: 'Group Activity',
    slices: [
      'Board/party game 🎲',
      'Watch movie 🎥',
      'Cook together 🍳',
      'Walk/hike 🚶',
      'Trivia night ❓',
      'Group workout 🏋️',
      'Karaoke 🎤',
      'Craft project ✂️',
      'Photo challenge 📸',
      'Shared playlist 🎶',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get familyNightSpinner => createSpinner(
    name: 'Family Night Idea',
    slices: [
      'Movie night 🎥',
      'Game night 🎲',
      'Pizza + dessert 🍕🍰',
      'Storytelling 📖',
      'Puzzle/LEGO 🧩',
      'Backyard activity 🌳',
      'Arts & crafts 🎨',
      'Talent show 🎭',
      'Yes Day ✅',
      'Photo memories 📷',
    ].map((text) => Slice(text: text)).toList(),
    colors: fiveSliceColors,
  );

  static SpinnerModel get homeworkTaskSpinner => createSpinner(
    name: 'Homework Task to Start With',
    slices: [
      'Reading assignment 📚',
      'Math problems ➗',
      'Study for quiz 📝',
      'Write paragraph ✍️',
      'Review notes 📖',
      'One worksheet 📄',
      'Organize materials 📂',
      'Research project 🔬',
      'Make flashcards 🃏',
      'Ask for help 🙋',
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
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.orange,
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
