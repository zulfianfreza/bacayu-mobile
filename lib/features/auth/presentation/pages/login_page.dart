import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // .value, NOT create: — AuthCubit is a singleton (app_router.dart's
    // redirect and the 401 interceptor both depend on this exact instance
    // staying alive); `create:` would have BlocProvider close it forever
    // the moment this page is popped.
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // `AuthCubit` is a singleton — if we landed here via an auto-logout
    // (see `SessionExpiredHandler`/`forceLogout`), that state transition
    // already happened before this page (and its BlocConsumer listener
    // below) even existed, so a plain `listener:` would never see it. Check
    // the CURRENT state once, post-frame so a Scaffold/ScaffoldMessenger
    // exists to show it in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      if (state is AuthUnauthenticated &&
          state.reason == UnauthenticatedReason.sessionExpired) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.sessionExpired)));
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
                  // Centred on a phone, and still a readable measure instead
                  // of an edge-to-edge form on a tablet.
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
                          l10n.welcomeBack,
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          label: l10n.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          icon: 'assets/icons/mail-stroke.png',
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
                          icon: 'assets/icons/lock-stroke.png',
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
                          label: l10n.login,
                          onPressed: _submit,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.slate200),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                l10n.orDivider,
                                style: AppTypography.caption,
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.slate200),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ChunkyButton(
                          label: l10n.continueWithGoogle,
                          variant: ChunkyButtonVariant.secondary,
                          icon: SvgPicture.asset(
                            'assets/icons/google-icon.svg',
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () =>
                              context.read<AuthCubit>().loginWithGoogle(),
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: Text(l10n.dontHaveAccount),
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
