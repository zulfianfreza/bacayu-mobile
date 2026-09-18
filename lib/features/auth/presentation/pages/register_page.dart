import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // .value, NOT create: — see the same note on LoginPage. AuthCubit is a
    // singleton; `create:` would close it (and its stream) when this page
    // is popped.
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go(
                state.user.hasOnboarded ? AppRoutes.home : AppRoutes.onboarding,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  // Same measure and centring as the login page — the two are
                  // one surface, and flicking between them should not move.
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.appName,
                          style: AppTypography.displaySm,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.createYourAccount,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          label: l10n.name,
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          icon: Icons.person_outline,
                          validator: (value) => (value == null || value.isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: l10n.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          icon: Icons.mail_outline,
                          validator: (value) => (value == null || value.isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: l10n.password,
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          icon: Icons.lock_outline,
                          validator: (value) => (value == null || value.isEmpty)
                              ? l10n.fieldRequired
                              : null,
                        ),
                        if (state is AuthError) ...[
                          const SizedBox(height: 16),
                          Text(
                            state.failure.localizedMessage(context),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ChunkyButton(
                          label: l10n.register,
                          onPressed: _submit,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(l10n.alreadyHaveAccount),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
