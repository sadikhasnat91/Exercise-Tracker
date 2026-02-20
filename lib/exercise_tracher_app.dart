import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';





class ExerciseTrackerApp extends StatelessWidget {
  const ExerciseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F121A),
        cardTheme: CardThemeData(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF1A1F2E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// MODELS
// ──────────────────────────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'date': date.toIso8601String(),
      'isProgressiveOverload': isProgressiveOverload,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      isProgressiveOverload: json['isProgressiveOverload'] as bool? ?? false,
    );
  }
}

class BodyWeightEntry {
  final double weight;
  final DateTime date;

  BodyWeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json) {
    return BodyWeightEntry(
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────────────────────────────────────

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

// ──────────────────────────────────────────────────────────────────────────────
// HOME PAGE
// ──────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WorkoutEntryPage(),
    const WorkoutHistoryPage(),
    const AnalyticsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add Workout'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// EXERCISE SUGGESTION LIBRARY
// ──────────────────────────────────────────────────────────────────────────────

final List<Map<String, String>> exerciseLibrary = [
  {'name': 'Bench Press', 'emoji': '🏋️‍♂️'},
  {'name': 'Squat', 'emoji': '🧍‍♂️⬇️'},
  {'name': 'Deadlift', 'emoji': '🏋️'},
  {'name': 'Overhead Press', 'emoji': '💪⬆️'},
  {'name': 'Pull Up', 'emoji': '💪🪢'},
  {'name': 'Push Up', 'emoji': '🙌⬇️'},
  {'name': 'Barbell Row', 'emoji': '🏋️‍♂️🔙'},
  {'name': 'Romanian Deadlift', 'emoji': '🧍‍♂️🔙'},
  {'name': 'Lunges', 'emoji': '🦵'},
  {'name': 'Leg Press', 'emoji': '🦵🏋️'},
  {'name': 'Bicep Curl', 'emoji': '💪🌀'},
  {'name': 'Tricep Extension', 'emoji': '💪⬆️'},
  {'name': 'Lateral Raise', 'emoji': '🦾⬅️➡️'},
  {'name': 'Plank', 'emoji': '🪨'},
  {'name': 'Crunches', 'emoji': '🤸'},
];

// ──────────────────────────────────────────────────────────────────────────────
// ADD WORKOUT PAGE - WITH VISUAL UPGRADE & LIBRARY
// ──────────────────────────────────────────────────────────────────────────────

class WorkoutEntryPage extends StatefulWidget {
  const WorkoutEntryPage({super.key});

  @override
  State<WorkoutEntryPage> createState() => _WorkoutEntryPageState();
}

class _WorkoutEntryPageState extends State<WorkoutEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isSaving = false;
  String _selectedUnit = 'KG';

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final unit = await getWeightUnit();
    setState(() => _selectedUnit = unit);
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
      final exercisesJson = prefs.getString('exercises') ?? '[]';
      List<dynamic> exercisesList = json.decode(exercisesJson);
      final name = _exerciseNameController.text.trim();
      final sets = int.parse(_setsController.text);
      final reps = int.parse(_repsController.text);
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final isOverload = _checkProgressiveOverload(exercisesList, name, sets, reps, weight);
      final newExercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        sets: sets,
        reps: reps,
        weight: weight,
        date: DateTime.now(),
        isProgressiveOverload: isOverload,
      );
      exercisesList.insert(0, newExercise.toJson());
      await prefs.setString('exercises', json.encode(exercisesList));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isOverload ? Icons.trending_up : Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(isOverload ? '🎉 Progressive Overload Achieved!' : 'Workout saved successfully!')),
            ],
          ),
          backgroundColor: isOverload ? Colors.green : Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _formKey.currentState!.reset();
      _exerciseNameController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving workout: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _checkProgressiveOverload(
      List<dynamic> storedList, String exerciseName, int sets, int reps, double weight) {
    try {
      final same = storedList
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .where((e) => e.name.toLowerCase() == exerciseName.toLowerCase())
          .toList();
      if (same.isEmpty) return false;
      same.sort((a, b) => b.date.compareTo(a.date));
      final last = same.first;
      final currentVolume = sets * reps * (weight > 0 ? weight : 1);
      return currentVolume > last.volume ||
          (weight > last.weight && weight > 0) ||
          sets > last.sets ||
          reps > last.reps;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero image section
                  Stack(
                    children: [
                      SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.45),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getGreeting(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fitness_center_rounded, size: 72, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            const Text('Log Your Workout', style: TextStyle(fontSize: 22, color: Colors.white)),
                            Text('Track your strength & progress', style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Exercise suggestion library
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: exerciseLibrary.length,
                              itemBuilder: (context, index) {
                                final ex = exerciseLibrary[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      _exerciseNameController.text = ex['name']!;
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundColor: Colors.teal.withOpacity(0.4),
                                          child: Text(ex['emoji']!, style: const TextStyle(fontSize: 36)),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          ex['name']!,
                                          style: const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Weight unit selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Weight Unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                SegmentedButton<String>(
                                  style: SegmentedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    selectedForegroundColor: Colors.white,
                                    backgroundColor: Colors.grey.shade700,
                                    selectedBackgroundColor: Colors.teal.shade700,
                                  ),
                                  segments: const [
                                    ButtonSegment(value: 'KG', label: Text('KG')),
                                    ButtonSegment(value: 'LB', label: Text('LB')),
                                  ],
                                  selected: {_selectedUnit},
                                  onSelectionChanged: (newSelection) => _saveUnit(newSelection.first),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          TextFormField(
                            controller: _exerciseNameController,
                            decoration: InputDecoration(
                              labelText: 'Exercise Name',
                              prefixIcon: const Icon(Icons.fitness_center),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _setsController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Sets',
                                    prefixIcon: const Icon(Icons.repeat),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return 'Required';
                                    final n = int.tryParse(v!);
                                    return n == null || n <= 0 ? 'Invalid' : null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _repsController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Reps',
                                    prefixIcon: const Icon(Icons.format_list_numbered),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  validator: (v) {
                                    if (v?.isEmpty ?? true) return 'Required';
                                    final n = int.tryParse(v!);
                                    return n == null || n <= 0 ? 'Invalid' : null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Weight ($_selectedUnit) - optional',
                              prefixIcon: const Icon(Icons.monitor_weight),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return null;
                              final n = double.tryParse(v!);
                              return n == null || n < 0 ? 'Invalid weight' : null;
                            },
                          ),

                          const SizedBox(height: 40),

                          FilledButton.icon(
                            onPressed: _isSaving ? null : _saveExercise,
                            icon: _isSaving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save),
                            label: Text(_isSaving ? 'Saving...' : 'Save Workout', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextButton.icon(
                            onPressed: () {
                              _formKey.currentState?.reset();
                              _exerciseNameController.clear();
                              _setsController.clear();
                              _repsController.clear();
                              _weightController.clear();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Form'),
                          ),
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
}

// ──────────────────────────────────────────────────────────────────────────────
// WORKOUT HISTORY PAGE - FULL CRUD
// ──────────────────────────────────────────────────────────────────────────────

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
    _loadUnit();
    _loadExercises();
  }

  Future<void> _loadUnit() async {
    final unit = await getWeightUnit();
    setState(() => _unit = unit);
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = prefs.getString('exercises') ?? '[]';
      final List<dynamic> rawList = json.decode(exercisesJson);
      final List<Exercise> validExercises = [];
      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            validExercises.add(Exercise.fromJson(item));
          } catch (_) {}
        }
      }
      validExercises.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _exercises = validExercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExercise(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = prefs.getString('exercises') ?? '[]';
      final List<dynamic> exercisesList = json.decode(exercisesJson);
      exercisesList.removeWhere((e) => e is Map && e['id'] == id);
      await prefs.setString('exercises', json.encode(exercisesList));
      _loadExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateExercise(Exercise oldExercise) async {
    final nameCtrl = TextEditingController(text: oldExercise.name);
    final setsCtrl = TextEditingController(text: oldExercise.sets.toString());
    final repsCtrl = TextEditingController(text: oldExercise.reps.toString());
    final weightCtrl = TextEditingController(text: oldExercise.weight > 0 ? oldExercise.weight.toStringAsFixed(1) : '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Workout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Exercise Name')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: setsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: repsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: weightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Weight ($_unit, optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final sets = int.tryParse(setsCtrl.text);
              final reps = int.tryParse(repsCtrl.text);
              final weight = double.tryParse(weightCtrl.text) ?? 0.0;
              if (nameCtrl.text.trim().isEmpty || sets == null || reps == null || sets <= 0 || reps <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid input')));
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != true) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = prefs.getString('exercises') ?? '[]';
      final List<dynamic> exercisesList = json.decode(exercisesJson);
      final updatedExercise = Exercise(
        id: oldExercise.id,
        name: nameCtrl.text.trim(),
        sets: int.parse(setsCtrl.text),
        reps: int.parse(repsCtrl.text),
        weight: double.tryParse(weightCtrl.text) ?? 0.0,
        date: oldExercise.date,
        isProgressiveOverload: false,
      );
      final index = exercisesList.indexWhere((e) => e is Map && e['id'] == oldExercise.id);
      if (index != -1) {
        exercisesList[index] = updatedExercise.toJson();
        await prefs.setString('exercises', json.encode(exercisesList));
        _loadExercises();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout updated')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Map<String, List<Exercise>> _groupedDates() {
    final groupedExercises = <String, List<Exercise>>{};
    for (var exercise in _exercises) {
      final dateKey = DateFormat('yyyy-MM-dd').format(exercise.date);
      groupedExercises.putIfAbsent(dateKey, () => []).add(exercise);
    }
    final sortedKeys = groupedExercises.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <String, List<Exercise>>{};
    for (var k in sortedKeys) sortedMap[k] = groupedExercises[k]!;
    return sortedMap;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMMM d').format(date);
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final weightText = exercise.weight > 0 ? ' @ ${exercise.weight.toStringAsFixed(1)} $_unit' : '';
    return Dismissible(
      key: Key(exercise.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Workout?'),
            content: Text('Delete "${exercise.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => _deleteExercise(exercise.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _updateExercise(exercise),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: exercise.isProgressiveOverload ? Colors.green.withOpacity(0.1) : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fitness_center,
                      color: exercise.isProgressiveOverload ? Colors.green : Theme.of(context).colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(exercise.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          if (exercise.isProgressiveOverload)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.trending_up, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text('PR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ]),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${exercise.sets} sets × ${exercise.reps} reps$weightText',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Volume: ${exercise.volume.toStringAsFixed(1)} $_unit',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Text(DateFormat('HH:mm').format(exercise.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExercises)],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _exercises.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No Workouts Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Start tracking your exercises to see your progress here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
              ],
            ),
          ),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 16.0;
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              itemCount: _groupedDates().length,
              itemBuilder: (context, index) {
                final grouped = _groupedDates();
                final dateKey = grouped.keys.elementAt(index);
                final exercises = grouped[dateKey]!;
                final date = DateTime.tryParse(dateKey) ?? DateTime.now();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _formatDateHeader(date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...exercises.map((e) => _buildExerciseCard(e)),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ANALYTICS PAGE
// ──────────────────────────────────────────────────────────────────────────────

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Week';
  String _unit = 'KG';

  @override
  void initState() {
    super.initState();
    _loadUnit();
    _loadExercises();
  }

  Future<void> _loadUnit() async {
    final unit = await getWeightUnit();
    setState(() => _unit = unit);
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('exercises') ?? '[]';
      final List<dynamic> rawList = json.decode(jsonString);
      final List<Exercise> valid = [];
      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            valid.add(Exercise.fromJson(item));
          } catch (_) {}
        }
      }
      valid.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _exercises = valid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Exercise> _getFilteredExercises() {
    final now = DateTime.now();
    if (_selectedPeriod == 'Week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return _exercises.where((e) => e.date.isAfter(weekAgo)).toList();
    } else {
      final monthAgo = DateTime(now.year, now.month - 1, now.day);
      return _exercises.where((e) => e.date.isAfter(monthAgo)).toList();
    }
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(child: _buildPeriodButton('Week')),
            const SizedBox(width: 8),
            Expanded(child: _buildPeriodButton('Month')),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return FilledButton(
      onPressed: () => setState(() => _selectedPeriod = period),
      style: FilledButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(period),
    );
  }

  Widget _buildStatsCards(BoxConstraints constraints) {
    final filtered = _getFilteredExercises();
    final totalWorkouts = filtered.length;
    final uniqueExercises = filtered.map((e) => e.name.toLowerCase()).toSet().length;
    final totalVolume = filtered.fold(0.0, (sum, e) => sum + e.volume);
    final progressiveOverloads = filtered.where((e) => e.isProgressiveOverload).length;
    final stats = [
      ['Total\nWorkouts', totalWorkouts.toString(), Icons.fitness_center, Colors.blue],
      ['Unique\nExercises', uniqueExercises.toString(), Icons.category, Colors.orange],
      ['Total\nVolume ($_unit)', totalVolume.toStringAsFixed(0), Icons.monitor_weight, Colors.purple],
      ['PRs', progressiveOverloads.toString(), Icons.trending_up, Colors.green],
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats.map((s) {
        return SizedBox(
          width: 160,
          height: 120,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(s[2] as IconData, size: 32, color: s[3] as Color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s[1] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(s[0] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkoutFrequencyChart(BoxConstraints constraints) {
    final filteredExercises = _getFilteredExercises();
    final workoutsByDay = <DateTime, int>{};
    for (var exercise in filteredExercises) {
      final dateOnly = DateTime(exercise.date.year, exercise.date.month, exercise.date.day);
      workoutsByDay[dateOnly] = (workoutsByDay[dateOnly] ?? 0) + 1;
    }
    if (workoutsByDay.isEmpty) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No workout data for this period'))),
      );
    }
    final sortedDates = workoutsByDay.keys.toList()..sort();
    final maxCount = workoutsByDay.values.reduce((a, b) => a > b ? a : b) + 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workout Frequency', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCount.toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedDates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(DateFormat('MM/dd').format(sortedDates[index]), style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: List.generate(sortedDates.length, (i) {
                    final count = workoutsByDay[sortedDates[i]] ?? 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExercisesChart() {
    final filtered = _getFilteredExercises();
    final exerciseCounts = <String, int>{};
    for (var e in filtered) {
      exerciseCounts[e.name] = (exerciseCounts[e.name] ?? 0) + 1;
    }
    if (exerciseCounts.isEmpty) return const SizedBox.shrink();
    final sorted = exerciseCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Exercises', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(top.length, (i) {
                    final total = top.fold(0, (s, e) => s + e.value);
                    final percentage = total > 0 ? (top[i].value / total * 100).toStringAsFixed(1) : '0';
                    return PieChartSectionData(
                      color: [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red][i % 5],
                      value: top[i].value.toDouble(),
                      title: '$percentage%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }),
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: List.generate(top.length, (i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red][i % 5], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${top[i].key} (${top[i].value})', style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressiveOverloadStats() {
    final filtered = _getFilteredExercises();
    final overloadCount = filtered.where((e) => e.isProgressiveOverload).length;
    final percentage = filtered.isEmpty ? 0.0 : (overloadCount / filtered.length * 100);
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.trending_up, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text('Progressive Overload', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$overloadCount / ${filtered.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 4),
            Text('${percentage.toStringAsFixed(1)}% of workouts', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExercises)],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _exercises.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No Data Yet', style: Theme.of(context).textTheme.headlineSmall),
              Text('Log some workouts to see analytics', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              _buildStatsCards(BoxConstraints.tight(const Size.fromWidth(600))),
              const SizedBox(height: 24),
              _buildWorkoutFrequencyChart(BoxConstraints.tight(const Size.fromWidth(600))),
              const SizedBox(height: 24),
              _buildTopExercisesChart(),
              const SizedBox(height: 24),
              _buildProgressiveOverloadStats(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// PROFILE PAGE - BODY WEIGHT TRACKER + PROFILE FEATURES
// ──────────────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _weightController = TextEditingController();
  final _nameController = TextEditingController();
  List<BodyWeightEntry> _entries = [];
  bool _isLoading = true;
  String _unit = 'KG';
  String _userName = '';
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUnit();
    _loadWeights();
    _loadProfile();
  }

  Future<void> _loadUnit() async {
    final unit = await getWeightUnit();
    setState(() => _unit = unit);
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        _profileImage = File(imagePath);
      }
      _nameController.text = _userName;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    setState(() => _userName = _nameController.text.trim());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedImage.path);
      setState(() => _profileImage = File(pickedImage.path));
    }
  }

  Future<void> _loadWeights() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final weightsJson = prefs.getString('body_weights') ?? '[]';
      final List<dynamic> rawList = json.decode(weightsJson);
      final List<BodyWeightEntry> loaded = rawList
          .map((e) => BodyWeightEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      loaded.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _entries = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWeight() async {
    final text = _weightController.text.trim();
    final weight = double.tryParse(text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight'), backgroundColor: Colors.red),
      );
      return;
    }
    final newEntry = BodyWeightEntry(weight: weight, date: DateTime.now());
    _entries.insert(0, newEntry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('body_weights', json.encode(_entries.map((e) => e.toJson()).toList()));
    _weightController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weight saved!'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _deleteWeightData(String period) async {
    final prefs = await SharedPreferences.getInstance();
    final weightsJson = prefs.getString('body_weights') ?? '[]';
    List<dynamic> list = json.decode(weightsJson);

    DateTime threshold = DateTime.now();
    switch (period) {
      case '1 day':
        threshold = threshold.subtract(const Duration(days: 1));
        break;
      case '1 week':
        threshold = threshold.subtract(const Duration(days: 7));
        break;
      case '1 month':
        threshold = threshold.subtract(const Duration(days: 30));
        break;
      case 'all':
        list = [];
        break;
    }

    if (period != 'all') {
      list = list.where((e) {
        final entry = BodyWeightEntry.fromJson(e as Map<String, dynamic>);
        return entry.date.isBefore(threshold);
      }).toList();
    }

    await prefs.setString('body_weights', json.encode(list));
    _loadWeights();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$period data deleted')));
  }

  Future<void> _deleteExerciseData(String period) async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getString('exercises') ?? '[]';
    List<dynamic> list = json.decode(exercisesJson);

    DateTime threshold = DateTime.now();
    switch (period) {
      case '1 day':
        threshold = threshold.subtract(const Duration(days: 1));
        break;
      case '1 week':
        threshold = threshold.subtract(const Duration(days: 7));
        break;
      case '1 month':
        threshold = threshold.subtract(const Duration(days: 30));
        break;
      case 'all':
        list = [];
        break;
    }

    if (period != 'all') {
      list = list.where((e) {
        final entry = Exercise.fromJson(e as Map<String, dynamic>);
        return entry.date.isBefore(threshold);
      }).toList();
    }

    await prefs.setString('exercises', json.encode(list));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$period exercise data deleted')));
  }

  void _showDeleteOptions(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type Data'),
        content: const Text('Choose period to delete:'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            if (type == 'Weight') _deleteWeightData('1 day');
            else _deleteExerciseData('1 day');
            Navigator.pop(context);
          }, child: const Text('1 Day')),
          TextButton(onPressed: () {
            if (type == 'Weight') _deleteWeightData('1 week');
            else _deleteExerciseData('1 week');
            Navigator.pop(context);
          }, child: const Text('1 Week')),
          TextButton(onPressed: () {
            if (type == 'Weight') _deleteWeightData('1 month');
            else _deleteExerciseData('1 month');
            Navigator.pop(context);
          }, child: const Text('1 Month')),
          TextButton(onPressed: () {
            if (type == 'Weight') _deleteWeightData('all');
            else _deleteExerciseData('all');
            Navigator.pop(context);
          }, child: const Text('All', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    if (_entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No weight data yet')),
        ),
      );
    }
    final sortedEntries = _entries.reversed.toList();
    final spots = sortedEntries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weight Trend ($_unit)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 3 == 0 && index < sortedEntries.length) {
                            return Text(DateFormat('MMM d').format(sortedEntries[index].date), style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: (sortedEntries.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(enabled: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null ? const Icon(Icons.person, size: 50) : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _saveProfile,
                        child: const Text('Save Name'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Current Weight ($_unit)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Weight ($_unit)',
                          hintText: 'e.g., 75.5',
                          prefixIcon: const Icon(Icons.monitor_weight),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saveWeight,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Weight'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildWeightChart(),
              const SizedBox(height: 24),
              _entries.isEmpty
                  ? Center(
                child: Column(
                  children: [
                    Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No weight entries yet', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(entry.weight.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${entry.weight.toStringAsFixed(1)} $_unit',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('EEEE, MMMM d • HH:mm').format(entry.date)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _showDeleteOptions('Weight'),
                icon: const Icon(Icons.delete),
                label: const Text('Delete Weight Data',style: TextStyle(color: Colors.white),),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _showDeleteOptions('Exercise'),
                icon: const Icon(Icons.delete),
                label: const Text('Delete Exercise Data',style: TextStyle(color: Colors.white),),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}