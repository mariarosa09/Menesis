import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // ─── Constants ───────────────────────────────────────────────────────────────
  // Sets how many OTP digit boxes are shown on screen.
  static const int _otpLength = 6;

  // ─── Getters ─────────────────────────────────────────────────────────────────
  // Returns the email passed from the previous screen to display to the user.
  String get _contactInfo => widget.email;

  // ─── OTP Input Controllers & Focus Nodes ─────────────────────────────────────
  // Each controller manages the text inside one OTP digit box.
  // Each focus node tracks which box is currently active (selected by the user).
  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());

  // ─── Resend Timer ────────────────────────────────────────────────────────────
  // Counts down from 30 seconds before allowing the user to resend the OTP.
  Timer? _resendTimer;
  int _secondsLeft = 30;
  bool get _canResend => _secondsLeft == 0;

  // ─── Lifecycle: initState ────────────────────────────────────────────────────
  // Runs once when the screen is first created.
  // Sets up focus listeners for each box and auto-focuses the first box.
  // Also starts the resend countdown timer.
  @override
  void initState() {
    super.initState();

    // For each OTP box, listen for when it gains focus.
    // If the user taps a box that is not the next empty one,
    // automatically redirect focus to the correct box.
    for (int i = 0; i < _otpLength; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          final correctIndex = _nextEmptyIndex();
          if (i != correctIndex) {
            Future.microtask(() => _focusNodes[correctIndex].requestFocus());
          }
        }
      });
    }

    // Wait for the first frame to finish drawing, then focus the first box.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });

    // Start the 30-second countdown for the resend button.
    _startResendTimer();
  }

  // ─── Resend Timer Logic ───────────────────────────────────────────────────────
  // Starts a repeating 1-second timer that counts down to zero.
  // Once it reaches zero, it stops and enables the resend button.
  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // Resets the countdown back to 30 and restarts the timer.
  // Called when the user taps "Resend".
  void _resetResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = 30);
    _startResendTimer();
  }

  // ─── Next Empty Box Finder ───────────────────────────────────────────────────
  // Scans the OTP boxes from left to right and returns the index
  // of the first box that has no digit yet.
  // If all boxes are filled, returns the last index.
  int _nextEmptyIndex() {
    for (int i = 0; i < _otpLength; i++) {
      if (_controllers[i].text.isEmpty) return i;
    }
    return _otpLength - 1;
  }

  // ─── Single Digit Input Handler ───────────────────────────────────────────────
  // Called whenever the user types into an OTP box.
  // If multiple characters are entered (e.g., pasted), passes to the paste handler.
  // Otherwise, moves focus forward to the next box after a digit is entered.
  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      // Move to the next box after typing a digit.
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty) {
      // Last box filled — dismiss the keyboard.
      _focusNodes[index].unfocus();
    }
    setState(() {});
  }

  // ─── Paste Handler ────────────────────────────────────────────────────────────
  // Handles when the user pastes a string of digits.
  // Strips any non-digit characters and fills as many boxes as possible.
  // Moves focus to the last filled box.
  void _handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final slice = digits.substring(0, digits.length.clamp(0, _otpLength));
    for (int i = 0; i < slice.length; i++) {
      _controllers[i].text = slice[i];
    }
    final next = (slice.length - 1).clamp(0, _otpLength - 1);
    _focusNodes[next].requestFocus();
    setState(() {});
  }

  // ─── Backspace Key Handler ────────────────────────────────────────────────────
  // Detects when the user presses the Backspace key on a physical or virtual keyboard.
  // If the current box is empty and there is a box before it,
  // moves focus back and clears that previous box.
  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  // ─── Lifecycle: dispose ───────────────────────────────────────────────────────
  // Cleans up all controllers, focus nodes, and the timer when the screen is removed
  // from the widget tree to prevent memory leaks.
  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ─── Build: Main Screen Layout ────────────────────────────────────────────────
  // Draws the full screen with a gradient background, back button,
  // lock icon, title, subtitle, OTP input card, and resend row.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Soft gradient background from top to bottom.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7F3F5),
              Color(0xFFF1E6EA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // ─── Back Button ─────────────────────────────────────────────
                // Positioned at the left edge of the screen using Align
                // so it stays consistent across all screen sizes.
                // Tapping it navigates back to the previous screen.
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        splashColor:
                        const Color(0xFFB56A7E).withOpacity(0.2),
                        highlightColor:
                        const Color(0xFFB56A7E).withOpacity(0.3),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF3A1F3D),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Lock Icon ───────────────────────────────────────────────
                // Visual indicator that this screen is about security/verification.
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB56A7E).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFFB56A7E).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFFB56A7E),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Screen Title ─────────────────────────────────────────────
                // Tells the user what this screen is for.
                const Text(
                  'Verify Code',
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A1F3D),
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // ─── Subtitle / Instruction ────────────────────────────────────
                // Tells the user where the OTP was sent (email address).
                Text(
                  'Enter the 6-digit code sent to\n$_contactInfo',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    color: Color(0xFF44222B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ─── OTP Input Card ────────────────────────────────────────────
                // White card container that holds the OTP boxes,
                // the Verify button, and the resend row.
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFC),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Small label above the OTP boxes.
                      const Text(
                        'ENTER CODE',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB56A7E),
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── OTP Boxes Row ───────────────────────────────────────
                      // Renders one digit input box for each position in the OTP.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _otpLength,
                              (index) => _buildOtpBox(index),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── Verify Button ───────────────────────────────────────
                      // Only becomes active when all OTP boxes are filled.
                      _buildVerifyButton(),

                      const SizedBox(height: 24),

                      // ─── Divider with "or" label ─────────────────────────────
                      // Visual separator between the Verify button and the resend row.
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFFE8B7C3))),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFE8B7C3))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ─── Resend Row ──────────────────────────────────────────
                      // Shows a countdown timer while waiting.
                      // When the timer reaches zero, the text becomes tappable
                      // so the user can request a new OTP code.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive it? ",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          GestureDetector(
                            // Only allow tapping when the countdown has finished.
                            onTap: _canResend ? _onResendTapped : null,
                            child: Text(
                              _canResend
                                  ? 'Resend'
                                  : '00:${_secondsLeft.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _canResend
                                    ? const Color(0xFFB56A7E)
                                    : const Color(0xFF8C5566),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Resend OTP Action ────────────────────────────────────────────────────────
  // Called when the user taps "Resend" after the timer reaches zero.
  // Resets the timer and triggers a new OTP request.
  void _onResendTapped() {
    _resetResendTimer();

    // TODO: Ipadala ang bagong OTP sa email ng user mula sa database/backend.

  }

  // ─── OTP Box Builder ──────────────────────────────────────────────────────────
  // Creates a single digit input box with styling based on its current state:
  //   - Focused: highlighted border with a soft glow
  //   - Filled: tinted background to show a digit has been entered
  //   - Default: plain light background with a subtle border
  Widget _buildOtpBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: hasValue
            ? const Color(0xFFB56A7E).withOpacity(0.08)
            : const Color(0xFFFFF8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFB56A7E)
              : const Color(0xFFE8B7C3),
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
          BoxShadow(
            color: const Color(0xFFB56A7E).withOpacity(0.18),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ]
            : [],
      ),

      // KeyboardListener detects physical key presses (e.g., Backspace)
      // so the user can delete digits and move focus backwards naturally.
      // FIX: Using a stable, pre-created FocusNode to avoid memory leaks
      // from creating a new FocusNode on every rebuild.
      child: KeyboardListener(
        focusNode: _focusNodes[index],
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,

          // FIX: maxLength is 1, not 2.
          // Each box should hold exactly one digit.
          // Pasting multiple digits is handled separately in onChanged.
          maxLength: 1,

          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A1F3D),
            letterSpacing: 1,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (val) {
            // If somehow more than one character arrives (e.g., from paste),
            // keep only the last typed digit and let the paste handler fill the rest.
            if (val.length > 1) {
              _controllers[index].text = val[val.length - 1];
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _controllers[index].text.length),
              );
              _handlePaste(val);
              return;
            }
            _onOtpChanged(index, val);
          },
        ),
      ),
    );
  }

  // ─── Verify Button Builder ────────────────────────────────────────────────────
  // Draws the Verify button at the bottom of the OTP card.
  // The button is only active (colored and tappable) when all 6 boxes are filled.
  // While any box is still empty, it appears greyed out and does nothing when tapped.
  Widget _buildVerifyButton() {
    final isEnabled = _controllers.every((c) => c.text.isNotEmpty);

    return GestureDetector(
      onTap: isEnabled ? _onVerifyTapped : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: isEnabled ? const Color(0xFFB56A7E) : Colors.grey[300],
        ),
        child: Center(
          child: Text(
            'Verify',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isEnabled ? Colors.white : Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Verify Button Action ─────────────────────────────────────────────────────
  // Called when the user taps Verify with all 6 digits filled in.
  // Combines the digits into one OTP string, then sends it for verification.
  void _onVerifyTapped() {
    final otp = _controllers.map((c) => c.text).join();

    // TODO: I-verify ang OTP na ito sa database/backend gamit ang email ng user.
    // Kung tama ang OTP, i-navigate ang user sa susunod na screen.
    // Kung mali o expired na, magpakita ng error message.

  }
}