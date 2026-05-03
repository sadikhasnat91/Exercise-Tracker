import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// ── Notification helper ──────────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz_data.initializeTimeZones();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await _notificationsPlugin.initialize(settings);
  await _notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

Future<void> scheduleCardioReminder(String message, TimeOfDay time) async {
  final now = DateTime.now();
  var scheduled = DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
  await _notificationsPlugin.zonedSchedule(
    1,
    'Cardio Tomorrow 🏃',
    message,
    tz.TZDateTime.from(scheduled, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'cardio_channel',
        'Cardio Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> cancelCardioReminder() async {
  await _notificationsPlugin.cancel(1);
}

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

  // Per-page accent palette [Workout, Plan, History, Analytics, Profile, Cardio]
  static const List<Color> pageAccents = [
    Color(0xFF7C4DFF), // Workout – deep violet
    Color(0xFF00BCD4), // Plan – ocean teal
    Color(0xFFFFAB00), // History – amber gold
    Color(0xFF00E676), // Analytics – emerald
    Color(0xFFFF5252), // Profile – coral red
    Color(0xFFFF9800), // Cardio – orange
  ];
  static const List<String> pageImages = [
    'assets/IM1.jpeg',
    'assets/IM1.jpeg',
    'assets/IM1.jpeg',
    'assets/IM1.jpeg',
    'assets/IM1.jpeg',
    'assets/IM1.jpeg',
  ];
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// SHARED WIDGETS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

// ─────────────────────────────────────────────────────────────────────────────
// PER-PAGE BACKGROUND  — real gym images, unique overlay per route
// ─────────────────────────────────────────────────────────────────────────────

/// Each page gets its own gym image + accent color overlay
class _PageBg extends StatelessWidget {
  final int pageIndex;
  const _PageBg({super.key, this.pageIndex = 0});

  static const _images = _C.pageImages;
  static const _overlays = [
    Color(0x997C4DFF), // Workout  – violet
    Color(0x9900BCD4), // Plan     – teal
    Color(0x99FFAB00), // History  – amber
    Color(0x9900E676), // Analytics– emerald
    Color(0x99FF5252), // Profile  – coral
    Color(0x99FF9800), // Cardio   – orange
  ];

  @override
  Widget build(BuildContext context) {
    final idx = pageIndex.clamp(0, 5);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _images[idx],
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF08090F)),
        ),
        // Per-page accent tint
        ColoredBox(color: _overlays[idx].withAlpha(55)),
        // Dark vignette — light enough to keep photo visible
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x44000000), Color(0xAA000000)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper widget for hero image panels inside AppBar PreferredSize
class _HeroImg extends StatelessWidget {
  final int pageIndex;
  final double height;
  const _HeroImg({required this.pageIndex, this.height = 210});

  static const _images = _C.pageImages;
  static const _accents = [
    Color(0x337C4DFF), // Workout – violet
    Color(0x3300BCD4), // Plan    – teal
    Color(0x33FFAB00), // History – amber
    Color(0x3300E676), // Analytics– emerald
    Color(0x33FF5252), // Profile – coral
    Color(0x33FF9800), // Cardio  – orange
  ];
  static const _alignments = [
    Alignment(0.0, -0.2),
    Alignment(0.3, 0.0),
    Alignment(-0.2, 0.3),
    Alignment(0.0, -0.4),
    Alignment(-0.3, 0.1),
    Alignment(0.2, -0.1),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = pageIndex.clamp(0, 5);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _images[idx],
            fit: BoxFit.cover,
            alignment: _alignments[idx],
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF08090F)),
          ),
          // Subtle per-page accent tint — very light so the photo shows
          ColoredBox(color: _accents[idx]),
          // Gradient: transparent at top so gym image is visible,
          // dark at bottom so text is readable
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000), // barely-there at top
                  Color(0x88000000), // medium at middle
                  Color(0xCC000000), // darker at bottom for text legibility
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
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
  final Color? glowColor;

  const _GlassCard({
    required this.child,
    this.padding,
    this.radius,
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final br = radius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: br,
            border: Border.all(
              color: borderColor ?? _C.border,
              width: 0.7,
            ),
            boxShadow: glowColor != null
                ? [
                    BoxShadow(
                      color: glowColor!.withAlpha(45),
                      blurRadius: 20,
                      spreadRadius: -4,
                    )
                  ]
                : null,
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

/// Set modality options available when logging an exercise.
const List<String> kSetTypes = [
  'Normal',
  'Superset',
  'Drop Set',
  'Giant Set',
  'Pyramid',
  'Rest-Pause',
];

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final List<double> setWeights;
  final List<int> setReps;
  final String unit;
  final DateTime date;
  final bool isProgressiveOverload;
  final String setType;
  final List<String> pairedExercises;
  // Per-set weights & reps for paired exercises in Superset / Giant Set
  final List<double> pairedSetWeightsB;
  final List<int> pairedSetRepsB;
  final List<double> pairedSetWeightsC;
  final List<int> pairedSetRepsC;
  // Equipment type: 'barbell' | 'dumbbell'
  final String equipmentType;
  // Working set weight (for drop set — the starting weight before drops)
  final double workingSetWeight;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight = 0.0,
    this.setWeights = const [],
    this.setReps = const [],
    this.unit = 'KG',
    required this.date,
    this.isProgressiveOverload = false,
    this.setType = 'Normal',
    this.pairedExercises = const [],
    this.pairedSetWeightsB = const [],
    this.pairedSetRepsB = const [],
    this.pairedSetWeightsC = const [],
    this.pairedSetRepsC = const [],
    this.equipmentType = 'barbell',
    this.workingSetWeight = 0.0,
  });

  /// Effective weight for a single hand/side.
  /// For dumbbell, the stored weight is per dumbbell, total = weight * 2.
  double get effectiveTotalWeight {
    final w = weight > 0 ? weight : 0.0;
    return equipmentType == 'dumbbell' ? w * 2 : w.toDouble();
  }

  double _effectiveSetWeight(int i) {
    final w = (i < setWeights.length && setWeights[i] > 0)
        ? setWeights[i]
        : (weight > 0 ? weight : 1.0);
    return equipmentType == 'dumbbell' ? w * 2 : w.toDouble();
  }

  /// Raw volume in the exercise's own stored unit (for display only).
  double get volume {
    if (setWeights.isNotEmpty || setReps.isNotEmpty) {
      double total = 0;
      for (int i = 0; i < sets; i++) {
        final w = _effectiveSetWeight(i);
        final r =
            (i < setReps.length && setReps[i] > 0) ? setReps[i] : reps;
        total += w * r;
      }
      return total;
    }
    return sets * reps * (effectiveTotalWeight > 0 ? effectiveTotalWeight : 1);
  }

  /// Volume normalised to KG for cross-unit comparison and analytics.
  double get volumeInKg {
    final factor = unit == 'LB' ? 1.0 / 2.20462 : 1.0;
    return volume * factor;
  }

  /// avgWeight normalised to KG.
  double get avgWeightInKg {
    final factor = unit == 'LB' ? 1.0 / 2.20462 : 1.0;
    return avgWeight * factor;
  }

  double get avgWeight {
    if (setWeights.isNotEmpty && setWeights.any((w) => w > 0)) {
      final eff = setWeights.map((w) => equipmentType == 'dumbbell' ? w * 2 : w);
      return eff.reduce((a, b) => a + b) / setWeights.length;
    }
    return effectiveTotalWeight;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'setWeights': setWeights,
        'setReps': setReps,
        'unit': unit,
        'date': date.toIso8601String(),
        'isProgressiveOverload': isProgressiveOverload,
        'setType': setType,
        'pairedExercises': pairedExercises,
        'pairedSetWeightsB': pairedSetWeightsB,
        'pairedSetRepsB': pairedSetRepsB,
        'pairedSetWeightsC': pairedSetWeightsC,
        'pairedSetRepsC': pairedSetRepsC,
        'equipmentType': equipmentType,
        'workingSetWeight': workingSetWeight,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Unknown',
        sets: json['sets'] as int? ?? 0,
        reps: json['reps'] as int? ?? 0,
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        setWeights: (json['setWeights'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [],
        setReps: (json['setReps'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [],
        unit: json['unit'] as String? ?? 'KG',
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        isProgressiveOverload:
            json['isProgressiveOverload'] as bool? ?? false,
        setType: json['setType'] as String? ?? 'Normal',
        pairedExercises: (json['pairedExercises'] as List<dynamic>?)
                ?.map((e) => e as String)
                .where((s) => s.isNotEmpty)
                .toList() ??
            [],
        pairedSetWeightsB: (json['pairedSetWeightsB'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [],
        pairedSetRepsB: (json['pairedSetRepsB'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [],
        pairedSetWeightsC: (json['pairedSetWeightsC'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [],
        pairedSetRepsC: (json['pairedSetRepsC'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [],
        equipmentType: json['equipmentType'] as String? ?? 'barbell',
        workingSetWeight: (json['workingSetWeight'] as num?)?.toDouble() ?? 0.0,
      );
}

class BodyWeightEntry {
  final double weight;
  final String unit;
  final DateTime date;

  BodyWeightEntry({required this.weight, this.unit = 'KG', required this.date});

  /// Convert this entry's weight to [targetUnit] for display / charting.
  double inUnit(String targetUnit) {
    if (unit == targetUnit) return weight;
    if (targetUnit == 'LB') return weight * 2.20462;   // KG → LB
    return weight / 2.20462;                            // LB → KG
  }

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'unit': unit,
        'date': date.toIso8601String(),
      };

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json) =>
      BodyWeightEntry(
        weight: (json['weight'] as num).toDouble(),
        unit: json['unit'] as String? ?? 'KG',
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
          // Full-screen gym image background with per-page tint
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _PageBg(
                key: ValueKey(_currentIndex),
                pageIndex: _currentIndex,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _pages[_currentIndex],
            ),
          ),
          // Global floating cardio button — always on top of all pages
          Positioned(
            right: 20,
            bottom: 98,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardioPage()),
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withAlpha(120),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xCC080912),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: _C.pageAccents[_currentIndex].withAlpha(110),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.pageAccents[_currentIndex].withAlpha(65),
                    blurRadius: 30,
                    spreadRadius: -8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.add_circle_outline_rounded,
                      Icons.add_circle_rounded, 'Workout'),
                  _navItem(1, Icons.event_note_outlined,
                      Icons.event_note_rounded, 'Plan'),
                  _navItem(2, Icons.history_rounded,
                      Icons.history_rounded, 'History'),
                  _navItem(3, Icons.insights_rounded,
                      Icons.insights_rounded, 'Analytics'),
                  _navItem(4, Icons.person_outline_rounded,
                      Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int idx, IconData off, IconData on, String label) {
    final sel = _currentIndex == idx;
    final accent = _C.pageAccents[idx];
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? accent.withAlpha(38) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim, child: child),
              child: Icon(
                sel ? on : off,
                key: ValueKey(sel),
                color: sel ? accent : _C.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? accent : _C.textMuted,
              ),
              child: Text(label),
            ),
          ],
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
  final _workingSetWeightCtrl = TextEditingController(); // Drop set: working set weight
  List<TextEditingController> _setWeightCtrls = [];
  List<TextEditingController> _setRepsCtrls = [];
  bool _isSaving = false;
  String _selectedUnit = 'KG';
  String _setType = 'Normal';
  String _equipmentType = 'barbell'; // 'barbell' | 'dumbbell'
  int? _selectedExIdx;
  List<String> _savedExerciseNames = []; // for autocomplete
  // Paired exercise name controllers (Superset = B; Giant Set = B + C)
  final _pairedExCtrl1 = TextEditingController();
  final _pairedExCtrl2 = TextEditingController();
  // Per-set weight/reps for paired exercises B and C
  List<TextEditingController> _pairedWeightCtrlsB = [];
  List<TextEditingController> _pairedRepsCtrlsB = [];
  List<TextEditingController> _pairedWeightCtrlsC = [];
  List<TextEditingController> _pairedRepsCtrlsC = [];
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _loadUnit();
    _loadSavedNames();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
    _setsCtrl.addListener(_onSetsChanged);
  }

  Future<void> _loadSavedNames() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercises') ?? '[]';
    try {
      final list = json.decode(raw) as List;
      final names = list
          .whereType<Map<String, dynamic>>()
          .map((e) => e['name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (mounted) setState(() => _savedExerciseNames = names);
    } catch (_) {}
  }

  void _onSetsChanged() {
    final n = int.tryParse(_setsCtrl.text) ?? 0;
    _updateSetWeightCtrls(n.clamp(0, 20));
  }

  void _updateSetWeightCtrls(int count) {
    void _resize(List<TextEditingController> list) {
      while (list.length > count) list.removeLast().dispose();
      while (list.length < count) list.add(TextEditingController());
    }
    _resize(_setWeightCtrls);
    _resize(_setRepsCtrls);
    _resize(_pairedWeightCtrlsB);
    _resize(_pairedRepsCtrlsB);
    _resize(_pairedWeightCtrlsC);
    _resize(_pairedRepsCtrlsC);
    if (mounted) setState(() {});
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
    if (_formKey.currentState == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('exercises') ?? '[]';
      List<dynamic> list = json.decode(raw);
      final name = _exerciseNameCtrl.text.trim();
      final sets = int.parse(_setsCtrl.text.trim());
      // Reps is optional: if left blank, per-set reps are used instead.
      final globalReps = int.tryParse(_repsCtrl.text.trim()) ?? 0;
      final setWeights = _setWeightCtrls
          .map((c) => double.tryParse(c.text.trim()) ?? 0.0)
          .toList();
      // For per-set reps: fall back to globalReps if a per-set value is empty.
      final setReps = _setRepsCtrls
          .map((c) => int.tryParse(c.text.trim()) ?? globalReps)
          .toList();
      // Require at least one reps value (global or per-set).
      final anyPerSetRep = setReps.any((r) => r > 0);
      if (globalReps <= 0 && !anyPerSetRep) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter reps — either in the Reps field or per set'),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
      // The stored top-level reps = global value, or average of per-set reps.
      final reps = globalReps > 0
          ? globalReps
          : (setReps.isNotEmpty
              ? (setReps.reduce((a, b) => a + b) / setReps.length).round()
              : 0);
      final avgWeight = setWeights.isNotEmpty && setWeights.any((w) => w > 0)
          ? setWeights.reduce((a, b) => a + b) / setWeights.length
          : double.tryParse(_weightCtrl.text.trim()) ?? 0.0;
      final isOverload = _checkOverload(list, name, sets, reps, avgWeight);
      final pairedSetWeightsB = _pairedWeightCtrlsB
          .map((c) => double.tryParse(c.text.trim()) ?? 0.0)
          .toList();
      final pairedSetRepsB = _pairedRepsCtrlsB
          .map((c) => int.tryParse(c.text.trim()) ?? 0)
          .toList();
      final pairedSetWeightsC = _pairedWeightCtrlsC
          .map((c) => double.tryParse(c.text.trim()) ?? 0.0)
          .toList();
      final pairedSetRepsC = _pairedRepsCtrlsC
          .map((c) => int.tryParse(c.text.trim()) ?? 0)
          .toList();
      final pairedExercises = [
        if (_setType == 'Superset' || _setType == 'Giant Set')
          _pairedExCtrl1.text.trim(),
        if (_setType == 'Giant Set') _pairedExCtrl2.text.trim(),
      ].where((s) => s.isNotEmpty).toList();
      final workingSetWeight = _setType == 'Drop Set'
          ? double.tryParse(_workingSetWeightCtrl.text.trim()) ?? 0.0
          : 0.0;
      final ex = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        sets: sets,
        reps: reps,
        weight: avgWeight,
        setWeights: setWeights,
        setReps: setReps,
        unit: _selectedUnit,
        date: DateTime.now(),
        isProgressiveOverload: isOverload,
        setType: _setType,
        pairedExercises: pairedExercises,
        pairedSetWeightsB: pairedSetWeightsB,
        pairedSetRepsB: pairedSetRepsB,
        pairedSetWeightsC: pairedSetWeightsC,
        pairedSetRepsC: pairedSetRepsC,
        equipmentType: _equipmentType,
        workingSetWeight: workingSetWeight,
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
      _workingSetWeightCtrl.clear();
      for (var c in _setWeightCtrls) c.clear();
      _updateSetWeightCtrls(0);
      _pairedExCtrl1.clear();
      _pairedExCtrl2.clear();
      for (var c in _pairedWeightCtrlsB) c.clear();
      for (var c in _pairedRepsCtrlsB) c.clear();
      for (var c in _pairedWeightCtrlsC) c.clear();
      for (var c in _pairedRepsCtrlsC) c.clear();
      setState(() {
        _selectedExIdx = null;
        _setType = 'Normal';
        _equipmentType = 'barbell';
      });
      _loadSavedNames();
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
      // Normalise the new weight to KG for a fair unit-independent comparison.
      final newWeightKg =
          _selectedUnit == 'LB' ? weight / 2.20462 : weight;
      final newVolumeKg =
          sets * reps * (newWeightKg > 0 ? newWeightKg : 1);
      return newVolumeKg > last.volumeInKg ||
          (newWeightKg > last.avgWeightInKg && newWeightKg > 0) ||
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
    _workingSetWeightCtrl.dispose();
    _pairedExCtrl1.dispose();
    _pairedExCtrl2.dispose();
    for (var c in _setWeightCtrls) c.dispose();
    for (var c in _setRepsCtrls) c.dispose();
    for (var c in _pairedWeightCtrlsB) c.dispose();
    for (var c in _pairedRepsCtrlsB) c.dispose();
    for (var c in _pairedWeightCtrlsC) c.dispose();
    for (var c in _pairedRepsCtrlsC) c.dispose();
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
                  // Workout page background — gym image, violet theme
                  const _HeroImg(pageIndex: 0, height: 260),
                  // Subtle bottom fade to blend into form area
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x88000000),
                          Color(0xFF06060F),
                        ],
                        stops: [0.0, 0.6, 1.0],
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

                    // ── Equipment Type Toggle (Dumbbell / Barbell) ──
                    _GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.fitness_center_rounded, size: 18, color: _C.textSecondary),
                              SizedBox(width: 10),
                              Text('Equipment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textSecondary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                _equipBtn('barbell', Icons.horizontal_rule_rounded, 'Barbell'),
                                _equipBtn('dumbbell', Icons.sports_gymnastics_rounded, 'Dumbbell'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Autocomplete Exercise Name ──
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _exerciseNameCtrl.text),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const [];
                        final q = textEditingValue.text.toLowerCase();
                        return _savedExerciseNames.where((n) => n.toLowerCase().contains(q));
                      },
                      displayStringForOption: (s) => s,
                      onSelected: (val) {
                        _exerciseNameCtrl.text = val;
                      },
                      fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                        ctrl.addListener(() {
                          _exerciseNameCtrl.text = ctrl.text;
                        });
                        return _glassField(
                          controller: ctrl,
                          focusNode: focusNode,
                          label: 'Exercise Name',
                          icon: Icons.fitness_center_rounded,
                          iconColor: _C.accent,
                          capitalization: TextCapitalization.words,
                          validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                        );
                      },
                      optionsViewBuilder: (ctx, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xEE1A1C2E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _C.border),
                              ),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: options.map((opt) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.history_rounded, color: _C.accent, size: 16),
                                  title: Text(opt, style: const TextStyle(color: _C.textPrimary, fontSize: 13)),
                                  onTap: () => onSelected(opt),
                                )).toList(),
                              ),
                            ),
                          ),
                        );
                      },
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
                              final trimmed = v?.trim() ?? '';
                              if (trimmed.isEmpty) return 'Required';
                              final n = int.tryParse(trimmed);
                              return n == null || n <= 0 ? 'Invalid' : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _glassField(
                            controller: _repsCtrl,
                            label: 'Reps (optional)',
                            // Global reps used only as save-time fallback for
                            // empty per-set reps. No live propagation.
                            icon: Icons.tag_rounded,
                            iconColor: _C.green,
                            inputType: TextInputType.number,
                            validator: (v) {
                              final trimmed = v?.trim() ?? '';
                              if (trimmed.isEmpty) return null; // optional
                              final n = int.tryParse(trimmed);
                              return n == null || n <= 0 ? 'Invalid' : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Set Type Selector ──
                    _GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.layers_rounded,
                                  size: 16, color: _C.cyan),
                              const SizedBox(width: 8),
                              const Text(
                                'Set Type',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _C.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 34,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: kSetTypes.map((type) {
                                final isSelected = _setType == type;
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _setType = type),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [
                                                    _C.cyan,
                                                    _C.accent
                                                  ])
                                            : null,
                                        color: isSelected
                                            ? null
                                            : Colors.white
                                                .withAlpha(12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : _C.border,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : _C.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // ── Context fields based on set type ──
                          if (_setType == 'Superset' ||
                              _setType == 'Giant Set') ...
                            [
                              const SizedBox(height: 12),
                              const Divider(
                                  color: _C.border, height: 1),
                              const SizedBox(height: 12),
                              Text(
                                _setType == 'Superset'
                                    ? 'Paired exercise'
                                    : 'Additional exercises',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _C.textMuted,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 8),
                              _inlineField(
                                controller: _pairedExCtrl1,
                                hint: 'Exercise B (e.g. Cable Fly)',
                                icon: Icons.fitness_center_rounded,
                                iconColor: _C.cyan,
                              ),
                              if (_setType == 'Giant Set') ...
                                [
                                  const SizedBox(height: 8),
                                  _inlineField(
                                    controller: _pairedExCtrl2,
                                    hint: 'Exercise C (e.g. Push Up)',
                                    icon: Icons.fitness_center_rounded,
                                    iconColor: _C.accentLight,
                                  ),
                                ],
                            ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_setType == 'Drop Set' &&
                        _setWeightCtrls.isNotEmpty) ...
                      [
                        _GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          borderColor: _C.coral.withAlpha(80),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: _C.coral.withAlpha(200)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Drop Set — enter starting weight, then each drop weight below.',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _C.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Working set weight
                        _glassField(
                          controller: _workingSetWeightCtrl,
                          label: 'Working Set Weight (starting weight)',
                          icon: Icons.monitor_weight_rounded,
                          iconColor: _C.coral,
                          inputType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final n = double.tryParse(v);
                            return n == null || n < 0 ? 'Invalid' : null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Drop count info
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _C.coral.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _C.coral.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.format_list_numbered_rounded, color: _C.coral, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Total drops: ${_setWeightCtrls.length}',
                                style: const TextStyle(color: _C.coral, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    if (_setWeightCtrls.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xAA1A1C2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: _C.amber.withAlpha(60), width: 0.8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.monitor_weight_rounded,
                                        size: 16, color: _C.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      _setType == 'Drop Set'
                                      ? 'Drop Set Details'
                                      : 'Per Set Details — optional',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: _C.textSecondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(width: 44),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Weight ($_selectedUnit)',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: _C.textMuted),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Center(
                                        child: Text(
                                          'Reps',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: _C.textMuted),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...List.generate(_setWeightCtrls.length, (i) {
                                  // For drop set, compute drop% from previous
                                  String? dropPct;
                                  if (_setType == 'Drop Set' && i > 0) {
                                    final prev = double.tryParse(
                                        _setWeightCtrls[i - 1].text.trim());
                                    final curr = double.tryParse(
                                        _setWeightCtrls[i].text.trim());
                                    if (prev != null &&
                                        curr != null &&
                                        prev > 0) {
                                      final pct =
                                          ((prev - curr) / prev * 100)
                                              .round();
                                      dropPct = '$pct% drop';
                                    }
                                  }
                                  final labelColor = _setType == 'Drop Set'
                                      ? _C.coral
                                      : _C.amber;
                                  final labelText = _setType == 'Drop Set'
                                      ? 'D${i + 1}'
                                      : 'S${i + 1}';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (dropPct != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 44, bottom: 3),
                                            child: Text(
                                              dropPct,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: _C.coral
                                                      .withAlpha(180),
                                                  fontWeight:
                                                      FontWeight.w600),
                                            ),
                                          ),
                                        Row(
                                          children: [
                                        SizedBox(
                                          width: 36,
                                          child: Text(
                                            labelText,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: labelColor
                                                  .withAlpha(200),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _setWeightCtrls[i],
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            style: const TextStyle(
                                                color: _C.textPrimary,
                                                fontSize: 14),
                                            decoration: InputDecoration(
                                              hintText: '0.0',
                                              hintStyle: const TextStyle(
                                                  fontSize: 13,
                                                  color: _C.textMuted),
                                              prefixIcon: Icon(
                                                  Icons.fitness_center_rounded,
                                                  size: 16,
                                                  color: labelColor
                                                      .withAlpha(160)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                            ),
                                            onChanged: _setType == 'Drop Set'
                                                ? (_) => setState(() {})
                                                : null,
                                            validator: (v) {
                                              if (v == null ||
                                                  v.trim().isEmpty) {
                                                return null;
                                              }
                                              final n = double.tryParse(v);
                                              return n == null || n < 0
                                                  ? 'Invalid'
                                                  : null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _setRepsCtrls[i],
                                            keyboardType:
                                                TextInputType.number,
                                            style: const TextStyle(
                                                color: _C.textPrimary,
                                                fontSize: 14),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle: const TextStyle(
                                                  fontSize: 13,
                                                  color: _C.textMuted),
                                              prefixIcon: Icon(
                                                  Icons.tag_rounded,
                                                  size: 16,
                                                  color: _C.green
                                                      .withAlpha(160)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                            ),
                                            validator: (v) {
                                              if (v == null ||
                                                  v.trim().isEmpty) {
                                                return null;
                                              }
                                              final n = int.tryParse(v);
                                              return n == null || n < 0
                                                  ? 'Invalid'
                                                  : null;
                                            },
                                          ),
                                        ),
                                      ],
                                        ),
                                        // Sub-rows for paired exercises
                                        if ((_setType == 'Superset' ||
                                                _setType == 'Giant Set') &&
                                            i < _pairedWeightCtrlsB.length)
                                          _pairedSetRow(
                                            label: 'B',
                                            color: _C.cyan,
                                            weightCtrl: _pairedWeightCtrlsB[i],
                                            repsCtrl: _pairedRepsCtrlsB[i],
                                          ),
                                        if (_setType == 'Giant Set' &&
                                            i < _pairedWeightCtrlsC.length)
                                          _pairedSetRow(
                                            label: 'C',
                                            color: _C.accentLight,
                                            weightCtrl: _pairedWeightCtrlsC[i],
                                            repsCtrl: _pairedRepsCtrlsC[i],
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      _glassField(
                        controller: _weightCtrl,
                        label: 'Weight ($_selectedUnit) — enter sets count first',
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
                    ],
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
                            color: Colors.white,
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
                        _workingSetWeightCtrl.clear();
                        for (var c in _setWeightCtrls) c.clear();
                        for (var c in _setRepsCtrls) c.clear();
                        _updateSetWeightCtrls(0);
                        _pairedExCtrl1.clear();
                        _pairedExCtrl2.clear();
                        for (var c in _pairedWeightCtrlsB) c.clear();
                        for (var c in _pairedRepsCtrlsB) c.clear();
                        for (var c in _pairedWeightCtrlsC) c.clear();
                        for (var c in _pairedRepsCtrlsC) c.clear();
                        setState(() {
                          _selectedExIdx = null;
                          _setType = 'Normal';
                          _equipmentType = 'barbell';
                        });
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

  Widget _equipBtn(String type, IconData icon, String label) {
    final active = _equipmentType == type;
    return GestureDetector(
      onTap: () => setState(() => _equipmentType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [
                  type == 'barbell' ? _C.amber : _C.green,
                  type == 'barbell' ? const Color(0xFFFF8F00) : const Color(0xFF00C853),
                ])
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : _C.textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _C.textMuted,
              ),
            ),
            if (active && type == 'dumbbell') ...[
              const SizedBox(width: 4),
              const Text('×2', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    FocusNode? focusNode,
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
          focusNode: focusNode,
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

  /// Compact text field used inside the set-type card (no backdrop blur).
  Widget _inlineField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: _C.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _C.textMuted, fontSize: 12),
        prefixIcon: Icon(icon, color: iconColor, size: 16),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }

  /// A sub-row for a paired exercise (B or C) within a set.
  Widget _pairedSetRow({
    required String label,
    required Color color,
    required TextEditingController weightCtrl,
    required TextEditingController repsCtrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: color.withAlpha(80), width: 0.7),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style:
                  const TextStyle(color: _C.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle:
                    const TextStyle(fontSize: 12, color: _C.textMuted),
                prefixIcon: Icon(Icons.fitness_center_rounded,
                    size: 14, color: color.withAlpha(160)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v);
                return n == null || n < 0 ? 'Invalid' : null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: repsCtrl,
              keyboardType: TextInputType.number,
              style:
                  const TextStyle(color: _C.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle:
                    const TextStyle(fontSize: 12, color: _C.textMuted),
                prefixIcon: Icon(Icons.tag_rounded,
                    size: 14, color: color.withAlpha(160)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v);
                return n == null || n < 0 ? 'Invalid' : null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// ═══════════════════════════════════════════════════════════════════════════════
// PLAN MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class _PlanEntry {
  final String id;
  String title;
  String content;
  String type; // 'gym' | 'diet'
  final DateTime createdAt;

  _PlanEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
      };

  factory _PlanEntry.fromJson(Map<String, dynamic> j) => _PlanEntry(
        id: j['id'] as String,
        title: j['title'] as String? ?? 'Untitled',
        content: j['content'] as String? ?? '',
        type: j['type'] as String? ?? 'gym',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// TODAY'S PLAN PAGE  (CRUD — Gym & Diet tabs with FAB)
// ═══════════════════════════════════════════════════════════════════════════════

class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({super.key});
  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage>
    with SingleTickerProviderStateMixin {
  static const _storageKey = 'workout_plans_v2';
  List<_PlanEntry> _plans = [];
  bool _isLoading = true;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        _plans = list
            .whereType<Map<String, dynamic>>()
            .map(_PlanEntry.fromJson)
            .toList();
      } catch (_) {
        _plans = [];
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, json.encode(_plans.map((p) => p.toJson()).toList()));
  }

  void _showSnack(String msg, {Color color = _C.accent}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _openEditor({_PlanEntry? existing, String? defaultType}) async {
    final result = await Navigator.of(context).push<_PlanEntry>(
      MaterialPageRoute(
        builder: (_) => _PlanEditorPage(
          plan: existing,
          defaultType: defaultType ?? 'gym',
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      if (existing == null) {
        _plans.insert(0, result);
      } else {
        final idx = _plans.indexWhere((p) => p.id == result.id);
        if (idx != -1) _plans[idx] = result;
      }
    });
    await _save();
    _showSnack(existing == null ? 'Plan created!' : 'Plan updated!');
  }

  Future<void> _deletePlan(_PlanEntry plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Plan',
            style: TextStyle(color: _C.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Delete "${plan.title}"? This cannot be undone.',
            style: const TextStyle(color: _C.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _C.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: _C.coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _plans.removeWhere((p) => p.id == plan.id));
    await _save();
    _showSnack('Plan deleted.', color: _C.coral);
  }

  Widget _buildTabContent(String type) {
    final color = type == 'gym' ? _C.accent : _C.green;
    final typeLabel = type == 'gym' ? 'gym' : 'diet';
    final filtered = _plans.where((p) => p.type == type).toList();
    if (filtered.isEmpty) {
      return _buildEmptyState(
        type == 'gym'
            ? Icons.fitness_center_rounded
            : Icons.restaurant_rounded,
        'No ${type == 'gym' ? 'Gym' : 'Diet'} Plans Yet',
        'Tap "+ Add" to create your first ${typeLabel} plan',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _PlanCard(
        plan: filtered[i],
        accentColor: color,
        onEdit: () => _openEditor(existing: filtered[i], defaultType: type),
        onDelete: () => _deletePlan(filtered[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());
    // Which tab is active
    return AnimatedBuilder(
      animation: _tab,
      builder: (context, _) {
        final currentType = _tab.index == 0 ? 'gym' : 'diet';
        final fabColor = _tab.index == 0 ? _C.accent : _C.green;
        final fabLabel = _tab.index == 0 ? 'Add Gym Plan' : 'Add Diet Plan';
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(270),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                // Full gym image
                const _HeroImg(pageIndex: 1, height: 270),
                // Text — positioned above the TabBar
                Positioned(
                  left: 24,
                  bottom: 72,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4).withAlpha(38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF00BCD4).withAlpha(90)),
                        ),
                        child: Text(
                          _tab.index == 0 ? 'GYM SCHEDULE' : 'NUTRITION PLAN',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF00BCD4),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('My Plans',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                  color: Colors.black54,
                                  blurRadius: 10,
                                  offset: Offset(0, 3))
                            ],
                          )),
                      const SizedBox(height: 4),
                      Text(today,
                          style: const TextStyle(
                              fontSize: 13, color: _C.textSecondary)),
                    ],
                  ),
                ),
                // TabBar — pinned to the bottom of the header
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 8,
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
                            gradient: const LinearGradient(colors: [
                              Color(0xFF00BCD4),
                              Color(0xFF0097A7)
                            ]),
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
              ],
            ),
          ),
          body: Stack(
            children: [
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.accent))
                  : TabBarView(
                      controller: _tab,
                      children: [
                        _buildTabContent('gym'),
                        _buildTabContent('diet'),
                      ],
                    ),
              // FAB — above bottom nav bar
              Positioned(
                right: 16,
                bottom: 90,
                child: FloatingActionButton.extended(
                  heroTag: 'plan_fab',
                  onPressed: () =>
                      _openEditor(defaultType: currentType),
                  backgroundColor: fabColor,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(fabLabel,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card widget
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatefulWidget {
  final _PlanEntry plan;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanCard({
    super.key,
    required this.plan,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.plan.content.trim().isNotEmpty;
    final dateStr = DateFormat('MMM d, yyyy').format(widget.plan.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: widget.accentColor.withAlpha(60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — tap to expand/collapse
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.event_note_rounded,
                        color: widget.accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan.title,
                          style: const TextStyle(
                            color: _C.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(dateStr,
                            style: const TextStyle(
                                color: _C.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Expand/collapse chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color:
                          _expanded ? widget.accentColor : _C.textMuted,
                      size: 22,
                    ),
                  ),
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: _C.accentLight, size: 20),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_rounded,
                        color: _C.coral, size: 20),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                        color: widget.accentColor.withAlpha(50),
                        height: 1),
                    const SizedBox(height: 12),
                    Text(
                      hasContent
                          ? widget.plan.content.trim()
                          : 'No content yet…',
                      style: const TextStyle(
                        color: _C.textSecondary,
                        fontSize: 13,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan editor page — full-screen CRUD editor
// ─────────────────────────────────────────────────────────────────────────────

class _PlanEditorPage extends StatefulWidget {
  final _PlanEntry? plan;
  final String defaultType;
  const _PlanEditorPage({super.key, this.plan, required this.defaultType});

  @override
  State<_PlanEditorPage> createState() => _PlanEditorPageState();
}

class _PlanEditorPageState extends State<_PlanEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late String _type;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _type = widget.plan?.type ?? widget.defaultType;
    _titleCtrl = TextEditingController(text: widget.plan?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.plan?.content ?? '');
    _titleCtrl.addListener(_markDirty);
    _contentCtrl.addListener(_markDirty);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a plan title.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final entry = _PlanEntry(
      id: widget.plan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: _contentCtrl.text,
      type: _type,
      createdAt: widget.plan?.createdAt ?? DateTime.now(),
    );
    Navigator.of(context).pop(entry);
  }

  Color get _accentColor => _type == 'gym' ? _C.accent : _C.green;

  String get _hintText => _type == 'gym'
      ? 'Write your gym plan here…\n\nExample:\nDay 1 – Push\n  • Bench Press 4×8\n  • Incline DB Press 3×10\n  • Tricep Ext 3×12\n\nDay 2 – Pull\n  • Pull-Ups 4×8\n  • Barbell Row 4×10'
      : 'Write your diet plan here…\n\nExample:\nBreakfast:\n  • Oats + protein shake\n  • 3 eggs\n\nLunch:\n  • Rice + chicken + veggies\n\nSnack:\n  • Banana + peanut butter\n\nDinner:\n  • Salmon + salad';

  @override
  Widget build(BuildContext context) {
    final isNew = widget.plan == null;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.panel,
        title: Text(isNew ? 'New Plan' : 'Edit Plan',
            style: const TextStyle(
                color: _C.textPrimary, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: _C.textPrimary),
        actions: [
          AnimatedOpacity(
            opacity: _isDirty ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: TextButton.icon(
              onPressed: _isDirty ? _save : null,
              icon: Icon(Icons.save_rounded, color: _accentColor, size: 18),
              label: Text('Save',
                  style: TextStyle(
                      color: _accentColor, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type toggle (Gym / Diet) ──────────────────────────────────
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0x22FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: Row(
                children: [
                  _TypeToggleBtn(
                    label: 'Gym Plan',
                    icon: Icons.fitness_center_rounded,
                    selected: _type == 'gym',
                    color: _C.accent,
                    onTap: () => setState(() {
                      _type = 'gym';
                      _isDirty = true;
                    }),
                  ),
                  _TypeToggleBtn(
                    label: 'Diet Plan',
                    icon: Icons.restaurant_rounded,
                    selected: _type == 'diet',
                    color: _C.green,
                    onTap: () => setState(() {
                      _type = 'diet';
                      _isDirty = true;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Title field ───────────────────────────────────────────────
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                  color: _C.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Plan title…',
                hintStyle: TextStyle(
                    color: _C.textMuted.withAlpha(160), fontSize: 22),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: _accentColor.withAlpha(80))),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _accentColor, width: 2)),
                contentPadding:
                    const EdgeInsets.only(bottom: 8),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            // ── Content field — fills remaining space ─────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xBB12141F),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _accentColor.withAlpha(40), width: 0.8),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: TextField(
                      controller: _contentCtrl,
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
                        hintText: _hintText,
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
          ],
        ),
      ),
    );
  }
}

class _TypeToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggleBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha(40) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: selected
                ? Border.all(color: color.withAlpha(120), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? color : _C.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : _C.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
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
    // Immediately remove from local list for responsive UI
    setState(() => _exercises.removeWhere((e) => e.id == id));
    // Then persist to storage
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercises') ?? '[]';
    final list = (json.decode(raw) as List)
      ..removeWhere((e) => e is Map && e['id'] == id);
    await prefs.setString('exercises', json.encode(list));
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
    final displayUnit = old.unit.isNotEmpty ? old.unit : _unit;

    // Build initial per-set weight controllers
    List<TextEditingController> setWeightCtrls;
    if (old.setWeights.isNotEmpty) {
      setWeightCtrls = old.setWeights
          .map((w) =>
              TextEditingController(text: w > 0 ? w.toStringAsFixed(1) : ''))
          .toList();
    } else {
      final n = old.sets.clamp(0, 20);
      setWeightCtrls = List.generate(
          n,
          (_) => TextEditingController(
              text: old.weight > 0 ? old.weight.toStringAsFixed(1) : ''));
    }

    // Build initial per-set reps controllers
    List<TextEditingController> setRepsCtrls;
    if (old.setReps.isNotEmpty) {
      setRepsCtrls = old.setReps
          .map((r) => TextEditingController(text: r > 0 ? r.toString() : ''))
          .toList();
    } else {
      final n = old.sets.clamp(0, 20);
      setRepsCtrls = List.generate(
          n,
          (_) => TextEditingController(
              text: old.reps > 0 ? old.reps.toString() : ''));
    }

    void updateCtrls(int newCount) {
      while (setWeightCtrls.length > newCount) {
        setWeightCtrls.removeLast().dispose();
      }
      while (setWeightCtrls.length < newCount) {
        setWeightCtrls.add(TextEditingController());
      }
      while (setRepsCtrls.length > newCount) {
        setRepsCtrls.removeLast().dispose();
      }
      while (setRepsCtrls.length < newCount) {
        setRepsCtrls.add(TextEditingController(text: repsCtrl.text));
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: StatefulBuilder(
          builder: (ctx2, setDialogState) => AlertDialog(
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
                      Expanded(
                        child: TextField(
                          controller: setsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: _C.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Sets'),
                          onChanged: (v) {
                            final n = int.tryParse(v) ?? 0;
                            setDialogState(
                                () => updateCtrls(n.clamp(0, 20)));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _dialogField(repsCtrl, 'Reps',
                              type: TextInputType.number)),
                    ],
                  ),
                  if (setWeightCtrls.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Per Set Details ($displayUnit)',
                        style: TextStyle(
                            color: _C.amber.withAlpha(220),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      setWeightCtrls.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(
                                'S${i + 1}',
                                style: TextStyle(
                                    color: _C.amber.withAlpha(200),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: setWeightCtrls[i],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style:
                                    const TextStyle(color: _C.textPrimary),
                                decoration: InputDecoration(
                                    labelText: 'Wt ${i + 1}'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: setRepsCtrls[i],
                                keyboardType: TextInputType.number,
                                style:
                                    const TextStyle(color: _C.textPrimary),
                                decoration: InputDecoration(
                                    labelText: 'Reps ${i + 1}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                        s == null ||
                        r == null ||
                        s <= 0 ||
                        r <= 0) {
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
      ),
    );

    if (ok != true) {
      for (var c in setWeightCtrls) c.dispose();
      for (var c in setRepsCtrls) c.dispose();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exercises') ?? '[]';
    final list = json.decode(raw) as List;
    final newSetWeights =
        setWeightCtrls.map((c) => double.tryParse(c.text.trim()) ?? 0.0).toList();
    final newSetReps =
        setRepsCtrls.map((c) => int.tryParse(c.text.trim()) ?? 0).toList();
    final avgWeight =
        newSetWeights.isNotEmpty && newSetWeights.any((w) => w > 0)
            ? newSetWeights.reduce((a, b) => a + b) / newSetWeights.length
            : 0.0;
    for (var c in setWeightCtrls) c.dispose();
    for (var c in setRepsCtrls) c.dispose();

    final updated = Exercise(
      id: old.id,
      name: nameCtrl.text.trim(),
      sets: int.parse(setsCtrl.text),
      reps: int.parse(repsCtrl.text),
      weight: avgWeight,
      setWeights: newSetWeights,
      setReps: newSetReps,
      unit: old.unit.isNotEmpty ? old.unit : _unit,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(210),
        child: ClipRect(
          child: Stack(
          children: [
            const _HeroImg(pageIndex: 2, height: 210),
            Positioned(
              left: 24,
              bottom: 22,
              right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFAB00).withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFFFAB00).withAlpha(90)),
                    ),
                    child: const Text('WORKOUT LOG',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFFAB00),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  const Text('History',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 3))
                        ],
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '${_exercises.length} session${_exercises.length == 1 ? '' : 's'} recorded',
                    style: const TextStyle(
                        fontSize: 13, color: _C.textSecondary),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              bottom: 14,
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: _C.textSecondary),
                onPressed: _loadData,
              ),
            ),
          ],
          ),
        ), // ClipRect
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
                                        const Color(0xFFFFAB00).withAlpha(40),
                                        const Color(0xFFFFAB00).withAlpha(15)
                                      ]),
                                    ),
                                    child: Text(
                                      _dateLabel(date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFFAB00),
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
                              key: ValueKey(e.id),
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
    super.key,
    required this.exercise,
    required this.unit,
    required this.onTap,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xEE1A1C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete?', style: TextStyle(color: _C.textPrimary)),
        content: Text('Delete "${exercise.name}"?',
            style: const TextStyle(color: _C.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _C.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: _C.coral)),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final displayUnit = exercise.unit.isNotEmpty ? exercise.unit : unit;
    final wt = exercise.weight > 0
        ? '${exercise.weight.toStringAsFixed(1)} $displayUnit'
        : '';

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
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xEE1A1C2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Delete?', style: TextStyle(color: _C.textPrimary)),
            content: Text('Delete "${exercise.name}"?',
                style: const TextStyle(color: _C.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: _C.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: _C.coral)),
              ),
            ],
          ),
        );
        return confirmed == true;
      },
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
                              if (exercise.setType != 'Normal')
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [_C.cyan, _C.accent]),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.layers_rounded,
                                          size: 11,
                                          color: Colors.white),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          exercise.setType,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
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
                              GestureDetector(
                                onTap: () => _confirmDelete(context),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: _C.coral.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded,
                                      color: _C.coral, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (exercise.pairedExercises.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  for (int pi = 0;
                                      pi < exercise.pairedExercises.length;
                                      pi++)
                                    _tag(
                                      '${String.fromCharCode(66 + pi)}: ${exercise.pairedExercises[pi]}',
                                      color: _C.cyan.withAlpha(30),
                                    ),
                                ],
                              ),
                            ),
                          if ((exercise.setWeights.isNotEmpty &&
                                  exercise.setWeights.any((w) => w > 0)) ||
                              (exercise.setReps.isNotEmpty &&
                                  exercise.setReps.any((r) => r > 0))) ...
                            [
                              // For superset / giant set show grouped per-set
                              if (exercise.setType == 'Superset' ||
                                  exercise.setType == 'Giant Set')
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    ...List.generate(exercise.sets, (i) {
                                      final hasW = i <
                                              exercise.setWeights.length &&
                                          exercise.setWeights[i] > 0;
                                      final hasR =
                                          i < exercise.setReps.length &&
                                              exercise.setReps[i] > 0;
                                      final weightStr = hasW
                                          ? '${exercise.setWeights[i].toStringAsFixed(1)} $displayUnit'
                                          : '';
                                      final repsStr = hasR
                                          ? '${exercise.setReps[i]}r'
                                          : '';
                                      final aLabel =
                                          [weightStr, repsStr]
                                              .where((s) => s.isNotEmpty)
                                              .join(' × ');

                                      // Exercise B
                                      final bHasW = i <
                                              exercise
                                                  .pairedSetWeightsB.length &&
                                          exercise.pairedSetWeightsB[i] > 0;
                                      final bHasR = i <
                                              exercise.pairedSetRepsB.length &&
                                          exercise.pairedSetRepsB[i] > 0;
                                      final bW = bHasW
                                          ? '${exercise.pairedSetWeightsB[i].toStringAsFixed(1)} $displayUnit'
                                          : '';
                                      final bR = bHasR
                                          ? '${exercise.pairedSetRepsB[i]}r'
                                          : '';
                                      final bLabel = [bW, bR]
                                          .where((s) => s.isNotEmpty)
                                          .join(' × ');

                                      // Exercise C (Giant Set only)
                                      final cHasW = exercise.setType ==
                                              'Giant Set' &&
                                          i <
                                              exercise
                                                  .pairedSetWeightsC.length &&
                                          exercise.pairedSetWeightsC[i] > 0;
                                      final cHasR = exercise.setType ==
                                              'Giant Set' &&
                                          i <
                                              exercise.pairedSetRepsC.length &&
                                          exercise.pairedSetRepsC[i] > 0;
                                      final cW = cHasW
                                          ? '${exercise.pairedSetWeightsC[i].toStringAsFixed(1)} $displayUnit'
                                          : '';
                                      final cR = cHasR
                                          ? '${exercise.pairedSetRepsC[i]}r'
                                          : '';
                                      final cLabel = [cW, cR]
                                          .where((s) => s.isNotEmpty)
                                          .join(' × ');

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Set ${i + 1}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: _C.textMuted,
                                                  fontWeight:
                                                      FontWeight.w600),
                                            ),
                                            const SizedBox(height: 3),
                                            Wrap(
                                              spacing: 5,
                                              runSpacing: 4,
                                              children: [
                                                if (aLabel.isNotEmpty)
                                                  _tag('A: $aLabel'),
                                                if (bLabel.isNotEmpty)
                                                  _tag('B: $bLabel',
                                                      color: _C.cyan
                                                          .withAlpha(30)),
                                                if (cLabel.isNotEmpty)
                                                  _tag('C: $cLabel',
                                                      color: _C.accentLight
                                                          .withAlpha(30)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    _tag(
                                        'Vol: ${exercise.volume.toStringAsFixed(0)} ${exercise.unit}'),
                                  ],
                                )
                              else
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _tag(
                                        '${exercise.sets}s × ${exercise.reps}r'),
                                    if (wt.isNotEmpty) _tag(wt),
                                    ...List.generate(exercise.sets, (i) {
                                      final hasW = i <
                                              exercise.setWeights.length &&
                                          exercise.setWeights[i] > 0;
                                      final hasR =
                                          i < exercise.setReps.length &&
                                              exercise.setReps[i] > 0;
                                      if (!hasW && !hasR) return null;
                                      final weightStr = hasW
                                          ? '${exercise.setWeights[i].toStringAsFixed(1)} $displayUnit'
                                          : '';
                                      final repsStr = hasR
                                          ? '${exercise.setReps[i]}r'
                                          : '';
                                      final label = [weightStr, repsStr]
                                          .where((s) => s.isNotEmpty)
                                          .join(' × ');
                                      final prefix =
                                          exercise.setType == 'Drop Set'
                                              ? 'D${i + 1}'
                                              : 'S${i + 1}';
                                      return _tag('$prefix: $label');
                                    }).whereType<Widget>(),
                                    _tag(
                                        'Vol: ${exercise.volume.toStringAsFixed(0)} ${exercise.unit}'),
                                  ],
                                ),
                            ]
                          else ...
                            [
                              Row(
                                children: [
                                  _tag(
                                      '${exercise.sets}s × ${exercise.reps}r'),
                                  if (wt.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    _tag(wt),
                                  ],
                                  const SizedBox(width: 6),
                                  _tag(
                                      'Vol: ${exercise.volume.toStringAsFixed(0)} ${exercise.unit}'),
                                ],
                              ),
                            ],
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

  Widget _tag(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withAlpha(12),
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
    // Sum volumes normalised to KG so mixed-unit entries are comparable.
    final vol = f.fold(0.0, (s, e) => s + e.volumeInKg);
    final prs = f.where((e) => e.isProgressiveOverload).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(210),
        child: Stack(
          children: [
            const _HeroImg(pageIndex: 3, height: 210),
            Positioned(
              left: 24,
              bottom: 22,
              right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _C.green.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.green.withAlpha(90)),
                    ),
                    child: const Text('YOUR STATS',
                        style: TextStyle(
                            fontSize: 11,
                            color: _C.green,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Analytics',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 3))
                        ],
                      )),
                  const SizedBox(height: 4),
                  Text(
                    _period == 'Week' ? 'Last 7 days overview' : 'Last 30 days overview',
                    style: const TextStyle(
                        fontSize: 13, color: _C.textSecondary),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              bottom: 14,
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: _C.textSecondary),
                onPressed: _load,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _C.green))
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
                        _statCard('Volume (KG)',
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
                ? LinearGradient(
                    colors: [_C.green, const Color(0xFF00C853)])
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
  String _unit = 'KG';          // workout weight unit (read-only here)
  String _bodyWeightUnit = 'KG'; // separate body-weight unit
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
    _bodyWeightUnit = prefs.getString('body_weight_unit') ?? 'KG';
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

  Future<void> _saveBodyWeightUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('body_weight_unit', unit);
    setState(() => _bodyWeightUnit = unit);
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
    _entries.insert(
        0, BodyWeightEntry(weight: w, unit: _bodyWeightUnit, date: DateTime.now()));
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(210),
        child: Stack(
          children: [
            const _HeroImg(pageIndex: 4, height: 210),
            Positioned(
              left: 24,
              bottom: 22,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _C.coral.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.coral.withAlpha(90)),
                    ),
                    child: const Text('YOUR PROFILE',
                        style: TextStyle(
                            fontSize: 11,
                            color: _C.coral,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userName.isNotEmpty ? 'Hey, $_userName' : 'Profile',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      shadows: [
                        Shadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 3))
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Track & manage your progress',
                      style: TextStyle(
                          fontSize: 13, color: _C.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _C.coral))
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Log Body Weight',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: _C.textPrimary),
                          ),
                          // KG / LB unit toggle
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                _bwUnitBtn('KG'),
                                _bwUnitBtn('LB'),
                              ],
                            ),
                          ),
                        ],
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
                                    labelText: 'Weight ($_bodyWeightUnit)',
                                    hintText:
                                        _bodyWeightUnit == 'KG' ? '75.5' : '165.0',
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
                                            '${entry.inUnit(_bodyWeightUnit).toStringAsFixed(1)} $_bodyWeightUnit',
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
    // Convert every entry to the current display unit
    final spots = sorted.asMap().entries
        .map((e) =>
            FlSpot(e.key.toDouble(), e.value.inUnit(_bodyWeightUnit)))
        .toList();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return _GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Trend ($_bodyWeightUnit)',
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
                              '${s.y.toStringAsFixed(1)} $_bodyWeightUnit',
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

  /// Small pill button used to toggle body-weight unit (KG / LB).
  Widget _bwUnitBtn(String label) {
    final active = _bodyWeightUnit == label;
    return GestureDetector(
      onTap: () => _saveBodyWeightUnit(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_C.cyan, Color(0xFF0097A7)])
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

// ═══════════════════════════════════════════════════════════════════════════════
// CARDIO MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class _CardioEntry {
  final String id;
  final String type; // e.g. Running, Cycling, Rowing…
  final int durationMinutes;
  final double distanceKm;
  final int calories;
  final DateTime date;
  final String notes;

  _CardioEntry({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.distanceKm,
    required this.calories,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'durationMinutes': durationMinutes,
        'distanceKm': distanceKm,
        'calories': calories,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory _CardioEntry.fromJson(Map<String, dynamic> j) => _CardioEntry(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'Cardio',
        durationMinutes: j['durationMinutes'] as int? ?? 0,
        distanceKm: (j['distanceKm'] as num?)?.toDouble() ?? 0.0,
        calories: j['calories'] as int? ?? 0,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        notes: j['notes'] as String? ?? '',
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARDIO PAGE
// ═══════════════════════════════════════════════════════════════════════════════

const List<String> kCardioTypes = [
  'Running',
  'Walking',
  'Cycling',
  'Rowing',
  'Jump Rope',
  'Swimming',
  'Elliptical',
  'HIIT',
  'Other',
];

class CardioPage extends StatefulWidget {
  const CardioPage({super.key});

  @override
  State<CardioPage> createState() => _CardioPageState();
}

class _CardioPageState extends State<CardioPage> {
  static const _storageKey = 'cardio_entries_v1';
  static const _reminderKey = 'cardio_reminder_enabled';
  static const _reminderHourKey = 'cardio_reminder_hour';
  static const _reminderMinKey = 'cardio_reminder_min';
  static const _reminderMsgKey = 'cardio_reminder_msg';

  List<_CardioEntry> _entries = [];
  bool _isLoading = true;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  String _reminderMsg = "Don't forget your cardio session today!";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderEnabled = prefs.getBool(_reminderKey) ?? false;
    _reminderTime = TimeOfDay(
      hour: prefs.getInt(_reminderHourKey) ?? 7,
      minute: prefs.getInt(_reminderMinKey) ?? 0,
    );
    _reminderMsg = prefs.getString(_reminderMsgKey) ??
        "Don't forget your cardio session today!";
    try {
      final raw = prefs.getString(_storageKey) ?? '[]';
      final list = (json.decode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(_CardioEntry.fromJson)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      if (mounted) setState(() { _entries = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, json.encode(_entries.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, _reminderEnabled);
    await prefs.setInt(_reminderHourKey, _reminderTime.hour);
    await prefs.setInt(_reminderMinKey, _reminderTime.minute);
    await prefs.setString(_reminderMsgKey, _reminderMsg);
    if (_reminderEnabled) {
      await scheduleCardioReminder(_reminderMsg, _reminderTime);
    } else {
      await cancelCardioReminder();
    }
  }

  Future<void> _showAddDialog() async {
    String selectedType = kCardioTypes.first;
    final durCtrl = TextEditingController();
    final distCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDs) => Dialog(
          backgroundColor: const Color(0xEE1A1C2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Cardio',
                      style: TextStyle(color: _C.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Type', style: TextStyle(color: _C.textMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: kCardioTypes.map((t) {
                      final sel = selectedType == t;
                      return GestureDetector(
                        onTap: () => setDs(() => selectedType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: sel
                                ? const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF57C00)])
                                : null,
                            color: sel ? null : Colors.white10,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                  color: sel ? Colors.white : _C.textSecondary,
                                  fontSize: 12,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _dialogField(durCtrl, 'Duration (min)', type: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _dialogField(distCtrl, 'Distance (km)', type: const TextInputType.numberWithOptions(decimal: true))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dialogField(calCtrl, 'Calories burned (optional)', type: TextInputType.number),
                  const SizedBox(height: 10),
                  _dialogField(notesCtrl, 'Notes (optional)'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel', style: TextStyle(color: _C.textMuted)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF57C00)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            final dur = int.tryParse(durCtrl.text.trim()) ?? 0;
                            if (dur <= 0) {
                              Navigator.pop(ctx, false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter duration in minutes')));
                              return;
                            }
                            Navigator.pop(ctx, true);
                          },
                          child: const Text('Save', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (ok != true) {
      durCtrl.dispose(); distCtrl.dispose(); calCtrl.dispose(); notesCtrl.dispose();
      return;
    }
    final entry = _CardioEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: selectedType,
      durationMinutes: int.tryParse(durCtrl.text.trim()) ?? 0,
      distanceKm: double.tryParse(distCtrl.text.trim()) ?? 0.0,
      calories: int.tryParse(calCtrl.text.trim()) ?? 0,
      date: DateTime.now(),
      notes: notesCtrl.text.trim(),
    );
    durCtrl.dispose(); distCtrl.dispose(); calCtrl.dispose(); notesCtrl.dispose();
    setState(() => _entries.insert(0, entry));
    await _save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cardio logged!'),
        backgroundColor: const Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> _deleteEntry(String id) async {
    setState(() => _entries.removeWhere((e) => e.id == id));
    await _save();
  }

  Future<void> _showReminderSheet() async {
    final msgCtrl = TextEditingController(text: _reminderMsg);
    bool enabled = _reminderEnabled;
    TimeOfDay time = _reminderTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheet) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xEE1A1C2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: _C.border, width: 0.5)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: _C.textMuted, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Tomorrow's Cardio Reminder",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _C.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enable reminder', style: TextStyle(color: _C.textSecondary)),
                      Switch(
                        value: enabled,
                        activeColor: const Color(0xFFFF9800),
                        onChanged: (v) => setSheet(() => enabled = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(context: ctx2, initialTime: time);
                      if (picked != null) setSheet(() => time = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _C.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: Color(0xFFFF9800)),
                          const SizedBox(width: 12),
                          Text(
                            'Notification time: ${time.format(ctx2)}',
                            style: const TextStyle(color: _C.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: msgCtrl,
                    style: const TextStyle(color: _C.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Reminder message',
                      hintText: 'e.g. 30 min run tomorrow!',
                      hintStyle: const TextStyle(color: _C.textMuted),
                      prefixIcon: const Icon(Icons.message_rounded, color: Color(0xFFFF9800)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF57C00)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: FilledButton(
                        onPressed: () async {
                          setState(() {
                            _reminderEnabled = enabled;
                            _reminderTime = time;
                            _reminderMsg = msgCtrl.text.trim().isEmpty
                                ? "Don't forget your cardio session today!"
                                : msgCtrl.text.trim();
                          });
                          await _saveReminderSettings();
                          if (ctx2.mounted) Navigator.pop(ctx2);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(enabled
                                  ? 'Reminder set for ${time.format(context)} tomorrow!'
                                  : 'Reminder cancelled'),
                              backgroundColor: const Color(0xFFFF9800),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ));
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save Reminder', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    msgCtrl.dispose();
  }

  TextField _dialogField(TextEditingController ctrl, String label, {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: _C.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _C.textMuted),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF9800)),
        ),
      ),
    );
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return 'Today';
    if (day == yest) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(d);
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(210),
        child: Stack(
          children: [
            const _HeroImg(pageIndex: 5, height: 210),
            // Back button
            Positioned(
              top: 40,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),
            Positioned(
              left: 24,
              bottom: 22,
              right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: orange.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: orange.withAlpha(90)),
                    ),
                    child: const Text('CARDIO LOG',
                        style: TextStyle(fontSize: 11, color: orange, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Cardio',
                      style: TextStyle(
                        fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))],
                      )),
                  const SizedBox(height: 4),
                  Text('${_entries.length} session${_entries.length == 1 ? '' : 's'} logged',
                      style: const TextStyle(fontSize: 13, color: _C.textSecondary)),
                ],
              ),
            ),
            Positioned(
              right: 8,
              bottom: 14,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _reminderEnabled ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                      color: _reminderEnabled ? orange : _C.textSecondary,
                    ),
                    onPressed: _showReminderSheet,
                    tooltip: 'Tomorrow\'s reminder',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: _C.textSecondary),
                    onPressed: _load,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9800)))
          : _entries.isEmpty
              ? _buildEmptyState(Icons.directions_run_rounded, 'No Cardio Yet',
                  'Tap + to log your first cardio session')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  itemCount: _entries.length,
                  itemBuilder: (_, i) {
                    final e = _entries[i];
                    return _CardioCard(
                      entry: e,
                      dateLabel: _dateLabel(e.date),
                      onDelete: () => _deleteEntry(e.id),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cardio_fab',
        onPressed: _showAddDialog,
        backgroundColor: orange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Log Cardio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _CardioCard extends StatelessWidget {
  final _CardioEntry entry;
  final String dateLabel;
  final VoidCallback onDelete;

  const _CardioCard({
    required this.entry,
    required this.dateLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800);
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_C.coral.withAlpha(20), _C.coral.withAlpha(100)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xEE1A1C2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Delete?', style: TextStyle(color: _C.textPrimary)),
            content: Text('Delete this ${entry.type} session?', style: const TextStyle(color: _C.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: _C.textMuted))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: _C.coral))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border, width: 0.6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [orange.withAlpha(60), orange.withAlpha(20)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.directions_run_rounded, color: orange, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(entry.type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPrimary)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: orange.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                              child: Text(dateLabel, style: const TextStyle(fontSize: 10, color: orange, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: _C.coral.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.delete_outline_rounded, color: _C.coral, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 4,
                          children: [
                            if (entry.durationMinutes > 0)
                              _tag('${entry.durationMinutes} min', Icons.timer_rounded),
                            if (entry.distanceKm > 0)
                              _tag('${entry.distanceKm.toStringAsFixed(1)} km', Icons.route_rounded),
                            if (entry.calories > 0)
                              _tag('${entry.calories} kcal', Icons.local_fire_department_rounded),
                          ],
                        ),
                        if (entry.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(entry.notes, style: const TextStyle(fontSize: 12, color: _C.textMuted, height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white12, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _C.textMuted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: _C.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
