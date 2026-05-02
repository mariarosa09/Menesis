import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  String get _contactInfo => widget.email;

  final List<TextEditingController> _controllers =
  List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  int _nextEmptyIndex() {
    for (int i = 0; i < _otpLength; i++) {
      if (_controllers[i].text.isEmpty) return i;
    }
    return _otpLength - 1;
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty) {
      _focusNodes[index].unfocus();
    }
    setState(() {});
  }

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

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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

                // Back button
                Transform.translate(
                  offset: const Offset(-170, -25),
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

                // Lock icon
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

                // Title
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

                //
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

                // Card
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
                      // Label
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

                      // OTP fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _otpLength,
                              (index) => _buildOtpBox(index),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Verify button
                      _buildVerifyButton(),

                      const SizedBox(height: 24),

                      // Divider
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

                      // Resend row
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
                          const Text(
                            '00:30',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8C5566),
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
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 2,
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

  Widget _buildVerifyButton() {
    final isEnabled = _controllers.every((c) => c.text.isNotEmpty);


    return GestureDetector(
      onTap: isEnabled ? () {} : null,
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
}