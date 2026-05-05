import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _obscurePassword = true;

  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User?  get _currentUser  => _auth.currentUser;
  String get _currentEmail => _currentUser?.email ?? '';

  Timer? _pollTimer;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a valid email.';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) return 'Please enter a valid email address.';
    if (value.trim().toLowerCase() == _currentEmail.toLowerCase()) return 'New email must be different from your current email.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your current password.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFB00020) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':   return 'This email is already used by another account.';
      case 'invalid-email':          return 'The email address format is not valid.';
      case 'wrong-password':
      case 'invalid-credential':     return 'Incorrect password. Please try again.';
      case 'requires-recent-login':  return 'Session expired. Please try again.';
      case 'too-many-requests':      return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'No internet connection. Please check your network.';
      case 'user-not-found':         return 'User not found. Please log in again.';
      default:                       return 'Something went wrong. Please try again.';
    }
  }

  void _popDialog() {
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _VerificationDialog(
        onResend: _resendVerification,
        onClose: () {
          _popDialog();
          _resetFlow();
        },
      ),
    );
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(newEmail: email),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) {
      _snack('No user is currently signed in.', isError: true);
      return;
    }

    _showLoadingDialog();

    try {
      final credential = EmailAuthProvider.credential(
        email: _currentEmail,
        password: _passwordCtrl.text,
      );
      await _currentUser!.reauthenticateWithCredential(credential);
      await _currentUser!.verifyBeforeUpdateEmail(_emailCtrl.text.trim());

      _popDialog();
      _showVerificationDialog();
      _startNewEmailPoller();
    } on FirebaseAuthException catch (e) {
      _popDialog();
      _snack(_friendlyError(e), isError: true);
    } catch (_) {
      _popDialog();
      _snack('Something went wrong. Please try again.', isError: true);
    }
  }

  void _startNewEmailPoller() {
    _pollTimer?.cancel();
    final intended = _emailCtrl.text.trim().toLowerCase();
    final confirmedEmail = _emailCtrl.text.trim();

    _pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        await _auth.currentUser?.reload();
        final updated = _auth.currentUser?.email?.toLowerCase();

        if (updated == intended) {
          timer.cancel();
          await _updateFirestoreEmail(_auth.currentUser!.uid, confirmedEmail);
          if (mounted) {
            _popDialog();
            _showSuccessDialog(confirmedEmail);
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              _popDialog();
              Navigator.pop(context);
            }
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _updateFirestoreEmail(String uid, String newEmail) async {
    try {
      await _firestore.collection('users').doc(uid).update({'email': newEmail});
    } catch (e) {
      debugPrint('Firestore email update failed: $e');
    }
  }

  Future<void> _resendVerification() async {
    try {
      await _currentUser!.verifyBeforeUpdateEmail(_emailCtrl.text.trim());
      _snack('Verification link resent.');
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyError(e), isError: true);
    } catch (_) {
      _snack('Failed to resend. Please try again.', isError: true);
    }
  }

  void _resetFlow() {
    _pollTimer?.cancel();
    if (mounted) {
      setState(() {
        _emailCtrl.clear();
        _passwordCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F3F5), Color(0xFFF1E6EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildCurrentEmailDisplay(),
                  const SizedBox(height: 20),
                  _styledInput(
                    controller: _emailCtrl,
                    label: 'NEW EMAIL',
                    hint: 'new@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  _styledInput(
                    controller: _passwordCtrl,
                    label: 'CURRENT PASSWORD',
                    hint: 'Enter your current password',
                    isPassword: true,
                    isVisible: !_obscurePassword,
                    toggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB56A7E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Verify New Email'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoNote(
                    'Enter your current password to confirm your identity. '
                        "We'll then send a verification link to your new email address.",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-15, 0),
          child: SizedBox(
            width: 45,
            height: 45,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                splashColor: const Color(0xFFB56A7E).withOpacity(0.2),
                highlightColor: const Color(0xFFB56A7E).withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.arrow_back, color: Color(0xFF3A1F3D)),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-15, 0),
          child: const Text(
            'Change Email',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A1F3D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentEmailDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CURRENT EMAIL',
          style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F3F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6B7C2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_currentEmail, style: const TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB56A7E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB56A7E).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFB56A7E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7A4E5D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F3F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6B7C2)),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: isPassword && !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LOADING DIALOG — unchanged
// ============================================================
class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFB56A7E)),
            SizedBox(height: 20),
            Text(
              'Verifying your identity\nand sending email link…',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF3A1F3D), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VERIFICATION DIALOG — unchanged
// ============================================================
class _VerificationDialog extends StatelessWidget {
  const _VerificationDialog({
    required this.onResend,
    required this.onClose,
  });

  final VoidCallback onResend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFB56A7E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  size: 40, color: Color(0xFFB56A7E)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Check your inbox',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A1F3D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'A verification link has been sent to your new email address. Click the link to complete the change.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFB56A7E)),
                ),
                SizedBox(width: 8),
                Text(
                  'Waiting for verification…',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB56A7E)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFB56A7E).withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: const Color(0xFFB56A7E).withOpacity(0.18)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFB56A7E)),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'This dialog will close automatically once your new email is confirmed.',
                      style:
                      TextStyle(fontSize: 11, color: Color(0xFF7A4E5D)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onResend,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Resend Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB56A7E),
                  side: const BorderSide(color: Color(0xFFB56A7E)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUCCESS DIALOG — unchanged
// ============================================================
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.newEmail});

  final String newEmail;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 52, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 22),
            const Text(
              'Email Updated!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A1F3D)),
            ),
            const SizedBox(height: 8),
            Text(
              'Your email has been changed to\n$newEmail',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}