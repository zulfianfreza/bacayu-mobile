import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class BacaYuApp extends StatelessWidget {
  const BacaYuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'BacaYu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: getIt<GoRouter>(),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
