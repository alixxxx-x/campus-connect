import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final names = _nameController.text.trim().split(' ');
      final firstName = names.isNotEmpty
          ? names.first
          : _nameController.text.trim();
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final error = await ref
          .read(authServiceProvider)
          .register(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: firstName,
            lastName: lastName,
            studentId: 'STU-${DateTime.now().millisecondsSinceEpoch}',
            role: 'STUDENT',
          );

      if (!mounted) {
        return;
      }

      if (error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Design Elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.03),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1E293B),
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Section
                            const Text(
                              'Join Us',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create your student account to get started',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 40),

                            if (_errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Registration Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AuthTextField(
                                    controller: _usernameController,
                                    label: 'Username',
                                    hint: 'Choose a username',
                                    prefixIcon: Icons.alternate_email_rounded,
                                    autofillHints: const [
                                      AutofillHints.newUsername,
                                    ],
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Username is required';
                                      if (value.length < 3)
                                        return 'Username too short';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    hint: 'Enter your full name',
                                    prefixIcon: Icons.person_outline_rounded,
                                    autofillHints: const [AutofillHints.name],
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Full name is required';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'user@example.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Email is required';
                                      if (!value.contains('@'))
                                        return 'Invalid email format';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Create a secure password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: true,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _register(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Password is required';
                                      if (value.length < 6)
                                        return 'At least 6 characters';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  AuthButton(
                                    text: 'Create Account',
                                    onPressed: _register,
                                    loading: _loading,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account?',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
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

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
