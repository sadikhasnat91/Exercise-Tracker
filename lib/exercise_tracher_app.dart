import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PALETTE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _C {
  static const bg = Color(0xFF08090F);
  static const panel = Color(0xCC12141F); // 80% opaque
  static const card = Color(0xBB1A1C2E); // 73% opaque
  static const cardSolid = Color(0xFF1A1C2E);
  static const border = Color(0x44FFFFFF);
  static const accent = Color(0xFF7C4DFF);
  static const accentLight = Color(0xFFB388FF);
  static const cyan = Color(0xFF00E5FF);
  static const coral = Color(0xFFFF6B6B);
  static const green = Color(0xFF69F0AE);
  static const amber = Color(0xFFFFD54F);
  static const textPrimary = Color(0xFFF0F0F8);
  static const textSecondary = Color(0xFFB0B0CC);
  static const textMuted = Color(0xFF7070A0);
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SHARED WIDGETS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// Full-page radial background image with dark overlay. Stays sticky.
class _BgImage extends StatelessWidget {
  const _BgImage();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/IM1.jpeg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}

/// Dark gradient overlay on top of the image.
class _BgOverlay extends StatelessWidget {
  final List<Color> colors;
  const _BgOverlay({required this.colors});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

/// Frosted-glass card with border glow.
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? radius;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.padding,
    this.radius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final br = radius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: br,
            border: Border.all(
              color: borderColor ?? _C.border,
              width: 0.6,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget _buildEmptyState(IconData icon, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _C.accent.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: _C.accent.withAlpha(60)),
          ),
          child: Icon(icon, size: 48, color: _C.accent.withAlpha(160)),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(color: _C.textMuted, fontSize: 14)),
      ],
    ),
  );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SPLASH LOGO WIDGET  (pure Flutter â€“ no image file needed)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: 200,
      height: 200,
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SPLASH WRAPPER  (entry point widget)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ExerciseTrackerApp(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D7377), // teal
              Color(0xFF14BDAC), // mid teal
              Color(0xFF0A3D62), // deep blue
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle radial glow in center
            Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withAlpha(18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with scale + fade
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Opacity(
                      opacity: _fade.value,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: const _SplashLogo(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tagline fade in
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Opacity(
                      opacity: _taglineFade.value,
                      child: Column(
                        children: [
                          const Text(
                            'Fit Log',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                    color: Colors.black38,
                                    blurRadius: 12,
                                    offset: Offset(0, 3)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'LOG SETS  *  REPS  *  PROGRESS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(180),
                              letterSpacing: 2.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Opacity(
                  opacity: _taglineFade.value,
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// APP ROOT
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class ExerciseTrackerApp extends StatelessWidget {
  const ExerciseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _C.accent,
          brightness: Brightness.dark,
        ).copyWith(primary: _C.accent, surface: _C.cardSolid),
        scaffoldBackgroundColor: _C.bg,
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: _C.cardSolid,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _C.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xAA1A1C2E),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: _C.border, width: 0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: _C.border, width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: _C.accent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: _C.textSecondary),
          hintStyle: const TextStyle(color: _C.textMuted),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xDD0E0F1A),
          indicatorColor: _C.accent.withAlpha(40),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _C.accent);
            }
            return const TextStyle(fontSize: 12, color: _C.textMuted);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _C.accent);
            }
            return const IconThemeData(color: _C.textMuted);
          }),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// MODELS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final DateTime date;
  final bool isProgressiveOverload;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight = 0.0,
    required this.date,
    this.isProgressiveOverload = false,
  });

  double get volume => sets * reps * (weight > 0 ? weight : 1);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'date': date.toIso8601String(),
        'isProgressiveOverload': isProgressiveOverload,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Unknown',
        sets: json['sets'] as int? ?? 0,
        reps: json['reps'] as int? ?? 0,
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        isProgressiveOverload:
            json['isProgressiveOverload'] as bool? ?? false,
      );
}

class BodyWeightEntry {
  final double weight;
  final DateTime date;

  BodyWeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'date': date.toIso8601String(),
      };

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json) =>
      BodyWeightEntry(
        weight: (json['weight'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// HELPERS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

Future<String> getWeightUnit() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('weight_unit') ?? 'KG';
}

Future<void> setWeightUnit(String unit) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('weight_unit', unit);
}

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  if (hour < 22) return 'Good Evening';
  return 'Good Night';
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// EXERCISE LIBRARY
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ExerciseItem {
  final String name;
  final IconData icon;
  final Color color;
  const _ExerciseItem(this.name, this.icon, this.color);
}

final List<_ExerciseItem> exerciseLibrary = [
  _ExerciseItem('Bench Press', Icons.airline_seat_flat_rounded, _C.accent),
  _ExerciseItem('Squat', Icons.accessibility_new_rounded, _C.cyan),
  _ExerciseItem('Deadlift', Icons.fitness_center_rounded, _C.coral),
  _ExerciseItem('Overhead Press', Icons.arrow_upward_rounded, _C.amber),
  _ExerciseItem('Pull Up', Icons.straighten_rounded, _C.green),
  _ExerciseItem('Push Up', Icons.back_hand_rounded, _C.accentLight),
  _ExerciseItem(
      'Barbell Row', Icons.rotate_left_rounded, const Color(0xFF4FC3F7)),
  _ExerciseItem('Romanian DL', Icons.swap_vert_rounded, _C.coral),
  _ExerciseItem('Lunges', Icons.directions_walk_rounded, _C.cyan),
  _ExerciseItem('Leg Press', Icons.expand_rounded, _C.green),
  _ExerciseItem(
      'Bicep Curl', Icons.sports_gymnastics_rounded, _C.amber),
  _ExerciseItem('Tricep Ext', Icons.arrow_downward_rounded, _C.accent),
  _ExerciseItem(
      'Lateral Raise', Icons.open_in_full_rounded, const Color(0xFFCE93D8)),
  _ExerciseItem('Plank', Icons.horizontal_rule_rounded, _C.cyan),
  _ExerciseItem(
      'Crunches', Icons.self_improvement_rounded, _C.green),
];

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// HOME PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    WorkoutEntryPage(),
    WorkoutPlanPage(),
    WorkoutHistoryPage(),
    AnalyticsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Persistent background image behind all pages
          const _BgImage(),
          const _BgOverlay(colors: [
            Color(0xCC08090F),
            Color(0xF508090F),
          ]),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _pages[_currentIndex],
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: _C.border, width: 0.5)),
            ),
            child: NavigationBar(
              height: 72,
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) =>
                  setState(() => _currentIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: 'Workout',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note_rounded),
                  label: 'Plan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: 'Analytics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// ADD WORKOUT PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class WorkoutEntryPage extends StatefulWidget {
  const WorkoutEntryPage({super.key});

  @override
  State<WorkoutEntryPage> createState() => _WorkoutEntryPageState();
}

class _WorkoutEntryPageState extends State<WorkoutEntryPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  bool _isSaving = false;
  String _selectedUnit = 'KG';
  int? _selectedExIdx;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _loadUnit();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  Future<void> _loadUnit() async {
    final u = await getWeightUnit();
    if (mounted) setState(() => _selectedUnit = u);
  }

  Future<void> _saveUnit(String unit) async {
    await setWeightUnit(unit);
    setState(() => _selectedUnit = unit);
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('exercises') ?? '[]';
      List<dynamic> list = json.decode(raw);
      final name = _exerciseNameCtrl.text.trim();
      final sets = int.parse(_setsCtrl.text);
      final reps = int.parse(_repsCtrl.text);
      final weight = double.tryParse(_weightCtrl.text) ?? 0.0;
      final isOverload = _checkOverload(list, name, sets, reps, weight);
      final ex = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        sets: sets,
        reps: reps,
        weight: weight,
        date: DateTime.now(),
        isProgressiveOverload: isOverload,
      );
      list.insert(0, ex.toJson());
      await prefs.setString('exercises', json.encode(list));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isOverload
                    ? Icons.emoji_events_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOverload
                      ? 'New PR! Progressive Overload!'
                      : 'Workout saved successfully!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor:
              isOverload ? _C.green.withAlpha(200) : _C.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
      _formKey.currentState!.reset();
      _exerciseNameCtrl.clear();
      _setsCtrl.clear();
      _repsCtrl.clear();
      _weightCtrl.clear();
      setState(() => _selectedExIdx = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: _C.coral),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _checkOverload(List<dynamic> stored, String name, int sets, int reps,
      double weight) {
    try {
      final same = stored
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .where((e) => e.name.toLowerCase() == name.toLowerCase())
          .toList();
      if (same.isEmpty) return false;
      same.sort((a, b) => b.date.compareTo(a.date));
      final last = same.first;
      return (sets * reps * (weight > 0 ? weight : 1)) > last.volume ||
          (weight > last.weight && weight > 0) ||
          sets > last.sets ||
          reps > last.reps;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _exerciseNameCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        slivers: [
          // â”€â”€ Hero image header â”€â”€
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/IM1.jpeg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.3)),
                  // Gradient over image
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x99000000),
                          Color(0xBB050510),
                          Color(0xFF08090F),
                        ],
                        stops: [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),
                  // Left-right vignette
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x66000000),
                          Colors.transparent,
                          Color(0x66000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _C.accent.withAlpha(50),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _C.accentLight.withAlpha(80)),
                          ),
                          child: Text(
                            getGreeting(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.accentLight,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Log Your\nWorkout',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Safe area top padding
                  Positioned(
                    top: topPad + 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: _C.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Fit Log',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // â”€â”€ Quick Pick label â”€â”€
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20, top: 8, bottom: 10),
              child: Text(
                'QUICK SELECT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _C.textMuted,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),

          // â”€â”€ Exercise chips â”€â”€
          SliverToBoxAdapter(
            child: SizedBox(
              height: 104,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: exerciseLibrary.length,
                itemBuilder: (context, index) {
                  final ex = exerciseLibrary[index];
                  final isSelected = _selectedExIdx == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        _exerciseNameCtrl.text = ex.name;
                        setState(() => _selectedExIdx = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 84,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ex.color.withAlpha(35)
                              : const Color(0xAA12141F),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? ex.color
                                : Colors.white12,
                            width: isSelected ? 1.5 : 0.6,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: ex.color.withAlpha(60),
                                    blurRadius: 16,
                                    spreadRadius: -2,
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: (isSelected
                                        ? ex.color
                                        : _C.textMuted)
                                    .withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                ex.icon,
                                size: 22,
                                color: isSelected
                                    ? ex.color
                                    : _C.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                ex.name.split(' ').first,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? ex.color
                                      : _C.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // â”€â”€ Form â”€â”€
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 24, 16, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Unit selector
                    _GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.scale_rounded,
                                  size: 18,
                                  color: _C.textSecondary),
                              SizedBox(width: 10),
                              Text(
                                'Weight Unit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _C.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _unitBtn('KG', _selectedUnit == 'KG'),
                                _unitBtn('LB', _selectedUnit == 'LB'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _glassField(
                      controller: _exerciseNameCtrl,
                      label: 'Exercise Name',
                      icon: Icons.fitness_center_rounded,
                      iconColor: _C.accent,
                      capitalization: TextCapitalization.words,
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _glassField(
                            controller: _setsCtrl,
                            label: 'Sets',
                            icon: Icons.repeat_rounded,
                            iconColor: _C.cyan,
                            inputType: TextInputType.number,
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Required';
                              final n = int.tryParse(v!);
                              return n == null || n <= 0 ? 'Invalid' : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _glassField(
                            controller: _repsCtrl,
                            label: 'Reps',
                            icon: Icons.tag_rounded,
                            iconColor: _C.green,
                            inputType: TextInputType.number,
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Required';
                              final n = int.tryParse(v!);
                              return n == null || n <= 0 ? 'Invalid' : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _glassField(
                      controller: _weightCtrl,
                      label: 'Weight ($_selectedUnit) - optional',
                      icon: Icons.monitor_weight_rounded,
                      iconColor: _C.amber,
                      inputType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return null;
                        final n = double.tryParse(v!);
                        return n == null || n < 0 ? 'Invalid weight' : null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Gradient save button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [_C.accent, Color(0xFF6200EA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _C.accent.withAlpha(80),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveExercise,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Workout',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        _exerciseNameCtrl.clear();
                        _setsCtrl.clear();
                        _repsCtrl.clear();
                        _weightCtrl.clear();
                        setState(() => _selectedExIdx = null);
                      },
                      child: const Text('Clear Form',
                          style: TextStyle(color: _C.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unitBtn(String label, bool active) {
    return GestureDetector(
      onTap: () => _saveUnit(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [_C.accent, Color(0xFF6200EA)])
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : _C.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType? inputType,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          textCapitalization: capitalization,
          validator: validator,
          style: const TextStyle(color: _C.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// ═══════════════════════════════════════════════════════════════════════════════
// TODAY'S PLAN PAGE  (notepad style — gym + diet)
// ═══════════════════════════════════════════════════════════════════════════════

class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({super.key});
  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _gymCtrl = TextEditingController();
  final _dietCtrl = TextEditingController();
  bool _isLoading = true;
  bool _gymEdited = false;
  bool _dietEdited = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
    _gymCtrl.addListener(() => setState(() => _gymEdited = true));
    _dietCtrl.addListener(() => setState(() => _dietEdited = true));
  }

  @override
  void dispose() {
    _tab.dispose();
    _gymCtrl.dispose();
    _dietCtrl.dispose();
    super.dispose();
  }

  String get _gymKey =>
      'notepad_gym_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
  String get _dietKey =>
      'notepad_diet_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _gymCtrl.text = prefs.getString(_gymKey) ?? '';
    _dietCtrl.text = prefs.getString(_dietKey) ?? '';
    if (mounted) {
      setState(() {
        _gymEdited = false;
        _dietEdited = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGym() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gymKey, _gymCtrl.text);
    if (mounted) {
      setState(() => _gymEdited = false);
      _showSaved();
    }
  }

  Future<void> _saveDiet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dietKey, _dietCtrl.text);
    if (mounted) {
      setState(() => _dietEdited = false);
      _showSaved();
    }
  }

  void _showSaved() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Text('Plan saved!', style: TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: _C.accent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Today's Plan"),
            Text(today,
                style: const TextStyle(
                    fontSize: 11,
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border),
                  ),
                  child: TabBar(
                    controller: _tab,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_C.accent, Color(0xFF6200EA)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    labelColor: Colors.white,
                    unselectedLabelColor: _C.textMuted,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center_rounded, size: 15),
                            SizedBox(width: 6),
                            Text('Gym Plan'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_rounded, size: 15),
                            SizedBox(width: 6),
                            Text('Diet Plan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.accent))
          : TabBarView(
              controller: _tab,
              children: [
                _NotepadTab(
                  controller: _gymCtrl,
                  accentColor: _C.accent,
                  hintText: 'Write your gym plan here...\n\nExample:\nDay 1 – Push\n  • Bench Press 4×8\n  • Incline DB Press 3×10\n  • Tricep Ext 3×12\n\nDay 2 – Pull\n  • Pull-Ups 4×8\n  • Barbell Row 4×10\n  ...',
                  isEdited: _gymEdited,
                  onSave: _saveGym,
                ),
                _NotepadTab(
                  controller: _dietCtrl,
                  accentColor: _C.green,
                  hintText: 'Write your diet plan here...\n\nExample:\nBreakfast:\n  • Oats + protein shake\n  • 3 eggs\n\nLunch:\n  • Rice + chicken + veggies\n\nSnack:\n  • Banana + peanut butter\n\nDinner:\n  • Salmon + salad',
                  isEdited: _dietEdited,
                  onSave: _saveDiet,
                ),
              ],
            ),
    );
  }
}

class _NotepadTab extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final String hintText;
  final bool isEdited;
  final VoidCallback onSave;

  const _NotepadTab({
    required this.controller,
    required this.accentColor,
    required this.hintText,
    required this.isEdited,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Save bar — only shows when there are unsaved changes
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isEdited ? 52 : 0,
          child: isEdited
              ? Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [accentColor, accentColor.withAlpha(160)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: accentColor.withAlpha(70),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('Save Changes',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(44)),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Notepad area — fills remaining space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xBB12141F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: accentColor.withAlpha(50), width: 0.8),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 15,
                      height: 1.75,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: _C.textMuted.withAlpha(110),
                        fontSize: 14,
                        height: 1.75,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// WORKOUT HISTORY PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String _unit = 'KG';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _unit = prefs.getString('weight_unit') ?? 'KG';
      final raw = prefs.getString('exercises') ?? '[]';
      final List<dynamic> rawList = json.decode(raw);
      final List<Exercise> result = [];
      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            result.add(Exercise.fromJson(item));
          } catch (_) {}
        }
      }
      result.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) setState(() { _exercises = result; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercises') ?? '[]';
    final list = (json.decode(raw) as List)
      ..removeWhere((e) => e is Map && e['id'] == id);
    await prefs.setString('exercises', json.encode(list));
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _edit(Exercise old) async {
    final nameCtrl = TextEditingController(text: old.name);
    final setsCtrl = TextEditingController(text: old.sets.toString());
    final repsCtrl = TextEditingController(text: old.reps.toString());
    final weightCtrl = TextEditingController(
        text: old.weight > 0 ? old.weight.toStringAsFixed(1) : '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xEE1A1C2E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Workout',
              style: TextStyle(color: _C.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Exercise Name'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _dialogField(setsCtrl, 'Sets',
                        type: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField(repsCtrl, 'Reps',
                        type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                _dialogField(weightCtrl, 'Weight ($_unit, optional)',
                    type: const TextInputType.numberWithOptions(
                        decimal: true)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: _C.textMuted)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.accent, Color(0xFF6200EA)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  final s = int.tryParse(setsCtrl.text);
                  final r = int.tryParse(repsCtrl.text);
                  if (nameCtrl.text.trim().isEmpty ||
                      s == null || r == null || s <= 0 || r <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Invalid input')));
                    return;
                  }
                  Navigator.pop(ctx, true);
                },
                child: const Text('Save',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercises') ?? '[]';
    final list = json.decode(raw) as List;
    final updated = Exercise(
      id: old.id,
      name: nameCtrl.text.trim(),
      sets: int.parse(setsCtrl.text),
      reps: int.parse(repsCtrl.text),
      weight: double.tryParse(weightCtrl.text) ?? 0.0,
      date: old.date,
    );
    final idx = list.indexWhere((e) => e is Map && e['id'] == old.id);
    if (idx != -1) {
      list[idx] = updated.toJson();
      await prefs.setString('exercises', json.encode(list));
      _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout updated')));
    }
  }

  TextField _dialogField(TextEditingController ctrl, String label,
      {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: _C.textPrimary),
      decoration: InputDecoration(labelText: label),
    );
  }

  Map<String, List<Exercise>> _groupByDate() {
    final grouped = <String, List<Exercise>>{};
    for (var e in _exercises) {
      final k = DateFormat('yyyy-MM-dd').format(e.date);
      grouped.putIfAbsent(k, () => []).add(e);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return 'Today';
    if (day == yest) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: _C.textSecondary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _C.accent))
          : _exercises.isEmpty
              ? _buildEmptyState(Icons.history_rounded, 'No Workouts Yet',
                  'Start logging to see history')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final key = grouped.keys.elementAt(i);
                    final exs = grouped[key]!;
                    final date =
                        DateTime.tryParse(key) ?? DateTime.now();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 10, left: 4),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        _C.accent.withAlpha(40),
                                        _C.accent.withAlpha(15)
                                      ]),
                                    ),
                                    child: Text(
                                      _dateLabel(date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _C.accentLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${exs.length} exercise${exs.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                    fontSize: 12, color: _C.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ...exs.map((e) => _ExHistoryCard(
                              exercise: e,
                              unit: _unit,
                              onTap: () => _edit(e),
                              onDelete: () => _delete(e.id),
                            )),
                        const SizedBox(height: 4),
                      ],
                    );
                  },
                ),
    );
  }
}

class _ExHistoryCard extends StatelessWidget {
  final Exercise exercise;
  final String unit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExHistoryCard({
    required this.exercise,
    required this.unit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final wt =
        exercise.weight > 0 ? '${exercise.weight.toStringAsFixed(1)} $unit' : '';

    return Dismissible(
      key: Key(exercise.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_C.coral.withAlpha(20), _C.coral.withAlpha(100)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async => await showDialog(
            context: context,
            builder: (_) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: const Color(0xEE1A1C2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                title: const Text('Delete?',
                    style: TextStyle(color: _C.textPrimary)),
                content: Text('Delete "${exercise.name}"?',
                    style: const TextStyle(color: _C.textSecondary)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: _C.textMuted)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete',
                        style: TextStyle(color: _C.coral)),
                  ),
                ],
              ),
            ),
          ) ??
          false,
      onDismissed: (_) => onDelete(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.border, width: 0.6),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: exercise.isProgressiveOverload
                              ? [
                                  _C.green.withAlpha(60),
                                  _C.green.withAlpha(20)
                                ]
                              : [
                                  _C.accent.withAlpha(50),
                                  _C.accent.withAlpha(15)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: exercise.isProgressiveOverload
                            ? _C.green
                            : _C.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textPrimary,
                                  ),
                                ),
                              ),
                              if (exercise.isProgressiveOverload)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          _C.green,
                                          Color(0xFF00C853)
                                        ]),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_up_rounded,
                                          size: 12,
                                          color: Color(0xFF08090F)),
                                      SizedBox(width: 3),
                                      Text(
                                        'PR',
                                        style: TextStyle(
                                          color: Color(0xFF08090F),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _tag('${exercise.sets}s x ${exercise.reps}r'),
                              if (wt.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                _tag(wt),
                              ],
                              const SizedBox(width: 6),
                              _tag(
                                  'Vol: ${exercise.volume.toStringAsFixed(0)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(exercise.date),
                      style: const TextStyle(
                          color: _C.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: _C.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// ANALYTICS PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String _period = 'Week';
  String _unit = 'KG';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _unit = prefs.getString('weight_unit') ?? 'KG';
    final raw = prefs.getString('exercises') ?? '[]';
    final list = json.decode(raw) as List;
    final valid = <Exercise>[];
    for (var e in list) {
      if (e is Map<String, dynamic>) {
        try { valid.add(Exercise.fromJson(e)); } catch (_) {}
      }
    }
    valid.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) setState(() { _exercises = valid; _isLoading = false; });
  }

  List<Exercise> get _filtered {
    final now = DateTime.now();
    if (_period == 'Week') {
      return _exercises
          .where((e) =>
              e.date.isAfter(now.subtract(const Duration(days: 7))))
          .toList();
    }
    return _exercises
        .where((e) =>
            e.date.isAfter(DateTime(now.year, now.month - 1, now.day)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final f = _filtered;
    final total = f.length;
    final unique = f.map((e) => e.name.toLowerCase()).toSet().length;
    final vol = f.fold(0.0, (s, e) => s + e.volume);
    final prs = f.where((e) => e.isProgressiveOverload).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: _C.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _C.accent))
          : _exercises.isEmpty
              ? _buildEmptyState(Icons.insights_rounded, 'No Data Yet',
                  'Log workouts to see analytics')
              : ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    // Period toggle
                    _GlassCard(
                      padding: const EdgeInsets.all(4),
                      radius: BorderRadius.circular(14),
                      child: Row(
                        children: [
                          _periodTab('Week'),
                          const SizedBox(width: 4),
                          _periodTab('Month'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.5,
                      children: [
                        _statCard('Workouts', '$total',
                            Icons.fitness_center_rounded, _C.accent),
                        _statCard('Exercises', '$unique',
                            Icons.category_rounded, _C.cyan),
                        _statCard('Volume ($_unit)',
                            vol.toStringAsFixed(0),
                            Icons.monitor_weight_rounded, _C.amber),
                        _statCard(
                            'PRs', '$prs', Icons.emoji_events_rounded, _C.green),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _freqChart(f),
                    const SizedBox(height: 16),
                    _topExercises(f),
                    const SizedBox(height: 16),
                    _overloadCard(f),
                    const SizedBox(height: 16),
                  ],
                ),
    );
  }

  Widget _periodTab(String label) {
    final active = _period == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _period = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [_C.accent, Color(0xFF6200EA)])
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _C.textMuted,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String title, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withAlpha(40), width: 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _C.textPrimary,
                    ),
                  ),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 11, color: _C.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _freqChart(List<Exercise> filtered) {
    final byDay = <DateTime, int>{};
    for (var e in filtered) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      byDay[d] = (byDay[d] ?? 0) + 1;
    }
    if (byDay.isEmpty) {
      return _GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No data for this period',
                style: const TextStyle(color: _C.textMuted)),
          ),
        ),
      );
    }
    final dates = byDay.keys.toList()..sort();
    final maxY = byDay.values.reduce((a, b) => a > b ? a : b) + 1;

    return _GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workout Frequency',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _C.textPrimary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                      '${rod.toY.toInt()} sessions\n${DateFormat('MMM d').format(dates[g.x])}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= dates.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(DateFormat('d').format(dates[i]),
                              style: const TextStyle(
                                  fontSize: 10, color: _C.textMuted)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 1,
                      getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(
                              fontSize: 10, color: _C.textMuted)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: _C.border, strokeWidth: 0.5),
                ),
                barGroups: List.generate(
                  dates.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (byDay[dates[i]] ?? 0).toDouble(),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFF6200EA),
                            _C.accent,
                            _C.accentLight
                          ],
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topExercises(List<Exercise> filtered) {
    final counts = <String, int>{};
    for (var e in filtered) {
      counts[e.name] = (counts[e.name] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = top.fold(0, (s, e) => s + e.value);
    final colors = [_C.accent, _C.green, _C.cyan, _C.amber, _C.coral];

    return _GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Exercises',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _C.textPrimary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: List.generate(
                  top.length,
                  (i) => PieChartSectionData(
                    color: colors[i % colors.length],
                    value: top[i].value.toDouble(),
                    title: total > 0
                        ? '${(top[i].value / total * 100).toStringAsFixed(0)}%'
                        : '0%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                pieTouchData: PieTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            top.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(top[i].key,
                        style: const TextStyle(
                            fontSize: 13, color: _C.textSecondary)),
                  ),
                  Text(
                    '${top[i].value}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overloadCard(List<Exercise> filtered) {
    final oc = filtered.where((e) => e.isProgressiveOverload).length;
    final pct = filtered.isEmpty ? 0.0 : oc / filtered.length;

    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up_rounded, color: _C.green, size: 24),
              SizedBox(width: 8),
              Text('Progressive Overload',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _C.textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 10,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(_C.green),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: _C.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$oc of ${filtered.length} workouts',
            style: const TextStyle(fontSize: 13, color: _C.textMuted),
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// PROFILE PAGE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _weightCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  List<BodyWeightEntry> _entries = [];
  bool _isLoading = true;
  String _unit = 'KG';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _unit = prefs.getString('weight_unit') ?? 'KG';
    _userName = prefs.getString('user_name') ?? '';
    _nameCtrl.text = _userName;
    try {
      final raw = prefs.getString('body_weights') ?? '[]';
      final loaded = (json.decode(raw) as List)
          .map((e) => BodyWeightEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      if (mounted) setState(() { _entries = loaded; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveName() async {
    await SharedPreferences.getInstance()
        .then((p) => p.setString('user_name', _nameCtrl.text.trim()));
    setState(() => _userName = _nameCtrl.text.trim());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Profile saved'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _saveWeight() async {
    final w = double.tryParse(_weightCtrl.text.trim());
    if (w == null || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Enter a valid weight'),
          backgroundColor: _C.coral));
      return;
    }
    _entries.insert(0, BodyWeightEntry(weight: w, date: DateTime.now()));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'body_weights', json.encode(_entries.map((e) => e.toJson()).toList()));
    _weightCtrl.clear();
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Weight saved!'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _deleteData(String type, String period) async {
    final prefs = await SharedPreferences.getInstance();
    final key = type == 'Weight' ? 'body_weights' : 'exercises';
    List<dynamic> list = json.decode(prefs.getString(key) ?? '[]');
    if (period == 'all') {
      list = [];
    } else {
      final days = period == '1 day' ? 1 : period == '1 week' ? 7 : 30;
      final thresh = DateTime.now().subtract(Duration(days: days));
      list = list.where((e) {
        final d = type == 'Weight'
            ? BodyWeightEntry.fromJson(e as Map<String, dynamic>).date
            : Exercise.fromJson(e as Map<String, dynamic>).date;
        return d.isBefore(thresh);
      }).toList();
    }
    await prefs.setString(key, json.encode(list));
    if (type == 'Weight') _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$period $type data deleted')));
  }

  void _showDeleteSheet(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xEE1A1C2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
                top: BorderSide(color: _C.border, width: 0.5)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _C.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Delete $type Data',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: _C.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  for (final period in ['1 day', '1 week', '1 month', 'all'])
                    ListTile(
                      leading: Icon(
                        period == 'all'
                            ? Icons.delete_forever_rounded
                            : Icons.delete_outline_rounded,
                        color: period == 'all' ? _C.coral : _C.textSecondary,
                      ),
                      title: Text(
                        period == 'all'
                            ? 'Delete All'
                            : 'Delete last $period',
                        style: TextStyle(
                            color: period == 'all'
                                ? _C.coral
                                : _C.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _deleteData(type, period);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _C.accent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // Profile card
                _GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_C.accent, Color(0xFF00BCD4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _C.accent.withAlpha(80),
                              blurRadius: 24,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _userName.isNotEmpty
                                ? _userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 6, sigmaY: 6),
                                child: TextFormField(
                                  controller: _nameCtrl,
                                  style: const TextStyle(
                                      color: _C.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Your Name',
                                    prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: _C.accent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_C.accent, Color(0xFF6200EA)]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.accent.withAlpha(60),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: _saveName,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Log body weight
                _GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log Body Weight',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _C.textPrimary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 6, sigmaY: 6),
                                child: TextFormField(
                                  controller: _weightCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  style: const TextStyle(
                                      color: _C.textPrimary),
                                  decoration: InputDecoration(
                                    labelText: 'Weight ($_unit)',
                                    hintText: '75.5',
                                    prefixIcon: const Icon(
                                        Icons.monitor_weight_rounded,
                                        color: _C.cyan),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_C.cyan, Color(0xFF0097A7)]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.cyan.withAlpha(60),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton.icon(
                              onPressed: _saveWeight,
                              icon: const Icon(Icons.add_rounded,
                                  size: 20),
                              label: const Text('Add'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Weight chart
                if (_entries.isNotEmpty) ...[
                  _buildWeightChart(),
                  const SizedBox(height: 16),

                  // Recent entries
                  _GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Entries',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: _C.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        ..._entries.take(10).map(
                              (entry) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            _C.cyan.withAlpha(25),
                                        borderRadius:
                                            BorderRadius.circular(11),
                                      ),
                                      child: const Icon(
                                          Icons.scale_rounded,
                                          size: 18,
                                          color: _C.cyan),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${entry.weight.toStringAsFixed(1)} $_unit',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: _C.textPrimary,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            DateFormat(
                                                    'MMM d, yyyy Â· h:mm a')
                                                .format(entry.date),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: _C.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Delete buttons
                Row(
                  children: [
                    Expanded(
                      child: _deleteBtn(
                        'Delete\nWorkout Data',
                        Icons.fitness_center_rounded,
                        () => _showDeleteSheet('Exercise'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _deleteBtn(
                        'Delete\nWeight Data',
                        Icons.monitor_weight_rounded,
                        () => _showDeleteSheet('Weight'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildWeightChart() {
    final sorted = _entries.reversed.toList();
    final spots = sorted.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return _GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Trend ($_unit)',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: _C.textPrimary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: _C.border, strokeWidth: 0.5),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (sorted.length / 5)
                          .ceilToDouble()
                          .clamp(1, double.infinity),
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= sorted.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                              DateFormat('M/d').format(sorted[i].date),
                              style: const TextStyle(
                                  fontSize: 10, color: _C.textMuted)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 10, color: _C.textMuted)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sorted.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(1)} $_unit',
                              const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    gradient: const LinearGradient(
                        colors: [_C.cyan, _C.accent]),
                    barWidth: 3,
                    dotData: FlDotData(show: spots.length < 20),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _C.cyan.withAlpha(50),
                          _C.accent.withAlpha(5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.coral.withAlpha(12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.coral.withAlpha(40), width: 0.6),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: _C.coral.withAlpha(180)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.coral.withAlpha(200),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
