import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/model.dart';
import '../app/strings.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('signUp', context)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              model.toggleLanguage();
            },
            icon: const Icon(Icons.language),
          ),
          IconButton(
            onPressed: () {
              model.toggleTheme();
            },
            icon: Icon(
              model.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Material(
                color: colorScheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.get('signUp', context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: AppStrings.get('name', context),
                            prefixIcon: const Icon(Icons.person_outline),
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          validator: (v) {
                            if (!model.supabaseEnabled) return null;
                            final value = (v ?? '').trim();
                            if (value.isEmpty) {
                              return AppStrings.get('requiredField', context);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppStrings.get('email', context),
                            prefixIcon: const Icon(Icons.email_outlined),
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          validator: (v) {
                            if (!model.supabaseEnabled) return null;
                            final value = (v ?? '').trim();
                            if (value.isEmpty) {
                              return AppStrings.get('requiredField', context);
                            }
                            if (!value.contains('@')) {
                              return AppStrings.get('invalidEmail', context);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: AppStrings.get('password', context),
                            prefixIcon: const Icon(Icons.lock_outline),
                            fillColor: colorScheme.surfaceContainerHighest,
                            suffixIcon: IconButton(
                              onPressed:
                                  () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (!model.supabaseEnabled) return null;
                            final value = (v ?? '').trim();
                            if (value.length < 6) {
                              return AppStrings.get('shortPassword', context);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirm,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: AppStrings.get(
                              'confirmPassword',
                              context,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          validator: (v) {
                            if (!model.supabaseEnabled) return null;
                            if ((v ?? '') != _password.text) {
                              return AppStrings.get(
                                'passwordMismatch',
                                context,
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 46,
                          child: FilledButton.icon(
                            onPressed:
                                _loading
                                    ? null
                                    : () {
                                      _submit(model);
                                    },
                            icon: const Icon(Icons.person_add_alt_1),
                            label:
                                _loading
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(AppStrings.get('signUp', context)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppStrings.get('haveAccount', context)),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(AppStrings.get('login', context)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(SustainabilityModel model) async {
    FocusScope.of(context).unfocus();
    if (!model.supabaseEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('supabaseNotConfigured', context)),
        ),
      );
      return;
    }
    if (model.supabaseEnabled) {
      final ok = _formKey.currentState?.validate() ?? false;
      if (!ok) return;
    }

    setState(() => _loading = true);
    try {
      await model.signUpWithPassword(
        email: _email.text.trim(),
        password: _password.text,
        fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      );
      if (!mounted) return;
      if (model.supabaseEnabled && !model.isAuthenticated) {
        await showDialog<void>(
          context: context,
          builder:
              (_) => AlertDialog(
                content: Text(AppStrings.get('checkEmail', context)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppStrings.get('ok', context)),
                  ),
                ],
              ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final lower = raw.toLowerCase();
      final isNetwork =
          lower.contains('socketexception') ||
          lower.contains('failed host lookup') ||
          lower.contains('no address associated with hostname') ||
          lower.contains('connection refused') ||
          lower.contains('timed out') ||
          lower.contains('permission denied');
      final msg =
          isNetwork
              ? AppStrings.get('networkError', context)
              : (e is AuthException ? e.message : raw);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
