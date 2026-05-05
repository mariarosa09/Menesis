import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CycleLengthSettingsScreen extends StatefulWidget {
  final int currentLength;
  final bool smartPredictionEnabled;

  const CycleLengthSettingsScreen({
    super.key,
    required this.currentLength,
    this.smartPredictionEnabled = true,
  });

  @override
  State<CycleLengthSettingsScreen> createState() =>
      _CycleLengthSettingsScreenState();
}

class _CycleLengthSettingsScreenState
    extends State<CycleLengthSettingsScreen> {
  late int _length;
  late bool _smartPrediction;
  bool _isSaving = false;

  static const int _min = 21;
  static const int _max = 35;

  @override
  void initState() {
    super.initState();
    _length = widget.currentLength.clamp(_min, _max);
    _smartPrediction = widget.smartPredictionEnabled;
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cycle')
          .doc('cycle info')
          .update({
        'cycle length': _length,
        'smart prediction': _smartPrediction,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Settings saved!"),
            backgroundColor: const Color(0xFFB56A7E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save. Try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool atMin = _length <= _min;
    final bool atMax = _length >= _max;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 36),

                        // Icon
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB56A7E), Color(0xFF7B3F61)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB56A7E)
                                    .withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.loop,
                              color: Colors.white, size: 32),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Cycle Length",
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "How many days is your typical cycle?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ── Smart Prediction toggle ──
                        _buildSmartPredictionCard(),

                        const SizedBox(height: 32),

                        // ── Stepper (disabled when smart prediction is ON) ──
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: _smartPrediction ? 0.4 : 1.0,
                          child: IgnorePointer(
                            ignoring: _smartPrediction,
                            child: _buildLargeStepper(
                                atMin: atMin, atMax: atMax),
                          ),
                        ),

                        // ── Helper message when smart prediction is ON ──
                        if (_smartPrediction) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB56A7E)
                                  .withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFB56A7E)
                                    .withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: const Color(0xFFB56A7E)
                                      .withOpacity(0.7),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Cycle length is managed automatically. Turn off Smart Prediction to set it manually.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFB56A7E),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 48),
                        _buildSaveButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF3A1F3D), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Cycle Length",
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A1F3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStepper({required bool atMin, required bool atMax}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _largeStepButton(
          icon: Icons.remove,
          enabled: !atMin,
          onTap: () => setState(() => _length--),
        ),
        const SizedBox(width: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Column(
            key: ValueKey(_length),
            children: [
              Text(
                "$_length",
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB56A7E),
                  height: 1,
                ),
              ),
              const Text(
                "days",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
        _largeStepButton(
          icon: Icons.add,
          enabled: !atMax,
          onTap: () => setState(() => _length++),
        ),
      ],
    );
  }

  Widget _largeStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? const Color(0xFFB56A7E).withOpacity(0.12)
              : Colors.grey.withOpacity(0.07),
        ),
        child: Icon(
          icon,
          size: 26,
          color: enabled ? const Color(0xFFB56A7E) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildSmartPredictionCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _smartPrediction
              ? const Color(0xFFB56A7E).withOpacity(0.35)
              : Colors.grey.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _smartPrediction
                ? const Color(0xFFB56A7E).withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _smartPrediction
                  ? const Color(0xFFB56A7E).withOpacity(0.12)
                  : Colors.grey.withOpacity(0.08),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 20,
              color: _smartPrediction
                  ? const Color(0xFFB56A7E)
                  : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Prediction",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _smartPrediction
                        ? const Color(0xFF3A1F3D)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Cycle length updates automatically.",
                  style: TextStyle(
                    fontSize: 11,
                    color: _smartPrediction
                        ? Colors.black45
                        : Colors.grey.shade400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _smartPrediction = !_smartPrediction),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: _smartPrediction
                    ? const Color(0xFFB56A7E)
                    : Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    left: _smartPrediction ? 22 : 2,
                    top: 2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
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

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB56A7E).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB56A7E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2),
        )
            : const Text(
          "Save",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}