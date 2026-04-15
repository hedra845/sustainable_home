import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/model.dart';
import '../app/strings.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('login', context)),
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
        child: Center(
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      image: AssetImage(
                                        'assets/logo_sustainable.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      image: AssetImage(
                                        'assets/ras_al_khaimah_university.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.get('appName', context),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.get('welcomeSubtitle', context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
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
                              icon: const Icon(Icons.login),
                              label:
                                  _loading
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(AppStrings.get('login', context)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppStrings.get('noAccount', context)),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(AppStrings.get('signUp', context)),
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
      await model.loginWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      if (!model.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('loginFailed', context))),
        );
      }
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
