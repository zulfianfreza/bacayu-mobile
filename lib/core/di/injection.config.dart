// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i584;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mobile/core/auth/google_sign_in_module.dart' as _i63;
import 'package:mobile/core/localization/locale_cubit.dart' as _i390;
import 'package:mobile/core/network/dio_client.dart' as _i873;
import 'package:mobile/core/network/session_expired_handler.dart' as _i387;
import 'package:mobile/core/router/app_router.dart' as _i683;
import 'package:mobile/core/sharing/services/share_card_service.dart' as _i239;
import 'package:mobile/core/storage/app_database.dart' as _i141;
import 'package:mobile/core/storage/secure_token_storage.dart' as _i839;
import 'package:mobile/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i1044;
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart'
    as _i950;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i202;
import 'package:mobile/features/auth/domain/usecases/complete_onboarding.dart'
    as _i310;
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart'
    as _i1052;
import 'package:mobile/features/auth/domain/usecases/login.dart' as _i189;
import 'package:mobile/features/auth/domain/usecases/login_with_google.dart'
    as _i60;
import 'package:mobile/features/auth/domain/usecases/logout.dart' as _i542;
import 'package:mobile/features/auth/domain/usecases/register.dart' as _i461;
import 'package:mobile/features/auth/domain/usecases/update_profile.dart'
    as _i362;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i948;
import 'package:mobile/features/badges/data/datasources/badge_remote_datasource.dart'
    as _i257;
import 'package:mobile/features/badges/data/repositories/badge_repository_impl.dart'
    as _i583;
import 'package:mobile/features/badges/domain/repositories/badge_repository.dart'
    as _i787;
import 'package:mobile/features/badges/domain/usecases/get_all_badges.dart'
    as _i437;
import 'package:mobile/features/badges/presentation/cubit/badge_cubit.dart'
    as _i945;
import 'package:mobile/features/books/data/datasources/book_remote_datasource.dart'
    as _i701;
import 'package:mobile/features/books/data/repositories/book_repository_impl.dart'
    as _i401;
import 'package:mobile/features/books/domain/repositories/book_repository.dart'
    as _i223;
import 'package:mobile/features/books/domain/usecases/add_manual_book.dart'
    as _i478;
import 'package:mobile/features/books/domain/usecases/get_book_detail.dart'
    as _i265;
import 'package:mobile/features/books/domain/usecases/import_book_from_google.dart'
    as _i451;
import 'package:mobile/features/books/domain/usecases/lookup_book_by_isbn.dart'
    as _i1069;
import 'package:mobile/features/books/domain/usecases/search_books.dart'
    as _i791;
import 'package:mobile/features/books/presentation/bloc/book_search_bloc.dart'
    as _i380;
import 'package:mobile/features/feed/data/datasources/feed_remote_datasource.dart'
    as _i932;
import 'package:mobile/features/feed/data/repositories/feed_repository_impl.dart'
    as _i487;
import 'package:mobile/features/feed/domain/repositories/feed_repository.dart'
    as _i674;
import 'package:mobile/features/feed/domain/usecases/get_feed.dart' as _i108;
import 'package:mobile/features/feed/domain/usecases/get_social_feed.dart'
    as _i52;
import 'package:mobile/features/feed/presentation/cubit/feed_cubit.dart'
    as _i498;
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart'
    as _i1054;
import 'package:mobile/features/notifications/data/datasources/notification_remote_datasource.dart'
    as _i593;
import 'package:mobile/features/notifications/data/repositories/notification_repository_impl.dart'
    as _i312;
import 'package:mobile/features/notifications/data/services/firebase_messaging_gateway.dart'
    as _i618;
import 'package:mobile/features/notifications/data/services/notification_navigator.dart'
    as _i567;
import 'package:mobile/features/notifications/data/services/push_notification_service.dart'
    as _i558;
import 'package:mobile/features/notifications/domain/repositories/notification_repository.dart'
    as _i224;
import 'package:mobile/features/notifications/domain/usecases/register_device.dart'
    as _i856;
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i423;
import 'package:mobile/features/profile/presentation/cubit/profile_cubit.dart'
    as _i704;
import 'package:mobile/features/sessions/data/datasources/session_local_datasource.dart'
    as _i677;
import 'package:mobile/features/sessions/data/datasources/session_remote_datasource.dart'
    as _i871;
import 'package:mobile/features/sessions/data/repositories/session_repository_impl.dart'
    as _i431;
import 'package:mobile/features/sessions/data/sync/session_sync_worker.dart'
    as _i104;
import 'package:mobile/features/sessions/domain/repositories/session_repository.dart'
    as _i769;
import 'package:mobile/features/sessions/domain/usecases/get_session_history.dart'
    as _i759;
import 'package:mobile/features/sessions/domain/usecases/submit_session.dart'
    as _i621;
import 'package:mobile/features/sessions/presentation/cubit/session_timer_cubit.dart'
    as _i928;
import 'package:mobile/features/shelf/data/datasources/shelf_remote_datasource.dart'
    as _i192;
import 'package:mobile/features/shelf/data/repositories/shelf_repository_impl.dart'
    as _i841;
import 'package:mobile/features/shelf/domain/repositories/shelf_repository.dart'
    as _i180;
import 'package:mobile/features/shelf/domain/usecases/add_to_shelf.dart'
    as _i640;
import 'package:mobile/features/shelf/domain/usecases/list_shelf.dart' as _i156;
import 'package:mobile/features/shelf/domain/usecases/update_shelf_status.dart'
    as _i88;
import 'package:mobile/features/shelf/presentation/cubit/shelf_cubit.dart'
    as _i1011;
import 'package:mobile/features/social/data/datasources/social_remote_datasource.dart'
    as _i27;
import 'package:mobile/features/social/data/repositories/social_repository_impl.dart'
    as _i912;
import 'package:mobile/features/social/domain/repositories/social_repository.dart'
    as _i784;
import 'package:mobile/features/social/domain/usecases/add_comment.dart'
    as _i241;
import 'package:mobile/features/social/domain/usecases/follow_user.dart'
    as _i242;
import 'package:mobile/features/social/domain/usecases/get_follow_counts.dart'
    as _i815;
import 'package:mobile/features/social/domain/usecases/get_leaderboard.dart'
    as _i643;
import 'package:mobile/features/social/domain/usecases/like_activity.dart'
    as _i426;
import 'package:mobile/features/social/domain/usecases/list_comments.dart'
    as _i375;
import 'package:mobile/features/social/domain/usecases/list_followers.dart'
    as _i334;
import 'package:mobile/features/social/domain/usecases/list_following.dart'
    as _i427;
import 'package:mobile/features/social/domain/usecases/unfollow_user.dart'
    as _i488;
import 'package:mobile/features/social/domain/usecases/unlike_activity.dart'
    as _i502;
import 'package:mobile/features/social/domain/usecases/update_activity_visibility.dart'
    as _i298;
import 'package:mobile/features/social/presentation/cubit/follow_cubit.dart'
    as _i442;
import 'package:mobile/features/social/presentation/cubit/leaderboard_cubit.dart'
    as _i481;
import 'package:mobile/features/stats/data/datasources/stats_remote_datasource.dart'
    as _i711;
import 'package:mobile/features/stats/data/repositories/stats_repository_impl.dart'
    as _i554;
import 'package:mobile/features/stats/domain/repositories/stats_repository.dart'
    as _i385;
import 'package:mobile/features/stats/domain/usecases/get_heatmap.dart'
    as _i485;
import 'package:mobile/features/stats/domain/usecases/get_stats_summary.dart'
    as _i884;
import 'package:mobile/features/stats/presentation/cubit/stats_cubit.dart'
    as _i428;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final googleSignInModule = _$GoogleSignInModule();
    final navigatorKeyModule = _$NavigatorKeyModule();
    final firebaseMessagingModule = _$FirebaseMessagingModule();
    final connectivityModule = _$ConnectivityModule();
    final dioClientModule = _$DioClientModule();
    final sessionExpiredHandlerModule = _$SessionExpiredHandlerModule();
    final appRouterModule = _$AppRouterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i239.ShareCardService>(() => const _i239.ShareCardService());
    gh.lazySingleton<_i116.GoogleSignIn>(
      () => googleSignInModule.googleSignIn(),
    );
    gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => navigatorKeyModule.navigatorKey,
    );
    gh.lazySingleton<_i141.AppDatabase>(() => _i141.AppDatabase());
    gh.lazySingleton<_i839.SecureTokenStorage>(
      () => _i839.SecureTokenStorage(),
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => firebaseMessagingModule.firebaseMessaging,
    );
    gh.lazySingleton<_i895.Connectivity>(() => connectivityModule.connectivity);
    gh.lazySingleton<_i618.FirebaseMessagingGateway>(
      () => _i618.FirebaseMessagingGatewayImpl(gh<_i892.FirebaseMessaging>()),
    );
    gh.lazySingleton<_i390.LocaleCubit>(
      () => _i390.LocaleCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioClientModule.dio(gh<_i839.SecureTokenStorage>()),
    );
    gh.lazySingleton<_i567.NotificationNavigator>(
      () => _i567.AppNotificationNavigator(
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
      ),
    );
    gh.factory<_i677.SessionLocalDataSource>(
      () => _i677.SessionLocalDataSource(gh<_i141.AppDatabase>()),
    );
    gh.factory<_i1044.AuthRemoteDataSource>(
      () => _i1044.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i257.BadgeRemoteDataSource>(
      () => _i257.BadgeRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i701.BookRemoteDataSource>(
      () => _i701.BookRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i932.FeedRemoteDataSource>(
      () => _i932.FeedRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i593.NotificationRemoteDataSource>(
      () => _i593.NotificationRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i871.SessionRemoteDataSource>(
      () => _i871.SessionRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i192.ShelfRemoteDataSource>(
      () => _i192.ShelfRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i27.SocialRemoteDataSource>(
      () => _i27.SocialRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i711.StatsRemoteDataSource>(
      () => _i711.StatsRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i385.StatsRepository>(
      () => _i554.StatsRepositoryImpl(gh<_i711.StatsRemoteDataSource>()),
    );
    gh.lazySingleton<_i784.SocialRepository>(
      () => _i912.SocialRepositoryImpl(gh<_i27.SocialRemoteDataSource>()),
    );
    gh.lazySingleton<_i787.BadgeRepository>(
      () => _i583.BadgeRepositoryImpl(gh<_i257.BadgeRemoteDataSource>()),
    );
    gh.factory<_i241.AddComment>(
      () => _i241.AddComment(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i242.FollowUser>(
      () => _i242.FollowUser(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i815.GetFollowCounts>(
      () => _i815.GetFollowCounts(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i643.GetLeaderboard>(
      () => _i643.GetLeaderboard(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i426.LikeActivity>(
      () => _i426.LikeActivity(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i375.ListComments>(
      () => _i375.ListComments(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i334.ListFollowers>(
      () => _i334.ListFollowers(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i427.ListFollowing>(
      () => _i427.ListFollowing(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i488.UnfollowUser>(
      () => _i488.UnfollowUser(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i502.UnlikeActivity>(
      () => _i502.UnlikeActivity(gh<_i784.SocialRepository>()),
    );
    gh.factory<_i298.UpdateActivityVisibility>(
      () => _i298.UpdateActivityVisibility(gh<_i784.SocialRepository>()),
    );
    gh.lazySingleton<_i674.FeedRepository>(
      () => _i487.FeedRepositoryImpl(gh<_i932.FeedRemoteDataSource>()),
    );
    gh.lazySingleton<_i224.NotificationRepository>(
      () => _i312.NotificationRepositoryImpl(
        gh<_i593.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i485.GetHeatmap>(
      () => _i485.GetHeatmap(gh<_i385.StatsRepository>()),
    );
    gh.factory<_i884.GetStatsSummary>(
      () => _i884.GetStatsSummary(gh<_i385.StatsRepository>()),
    );
    gh.lazySingleton<_i104.SessionSyncWorker>(
      () => _i104.SessionSyncWorker(
        gh<_i677.SessionLocalDataSource>(),
        gh<_i871.SessionRemoteDataSource>(),
        gh<_i895.Connectivity>(),
      ),
    );
    gh.lazySingleton<_i202.AuthRepository>(
      () => _i950.AuthRepositoryImpl(
        gh<_i1044.AuthRemoteDataSource>(),
        gh<_i839.SecureTokenStorage>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i856.RegisterDevice>(
      () => _i856.RegisterDevice(gh<_i224.NotificationRepository>()),
    );
    gh.lazySingleton<_i223.BookRepository>(
      () => _i401.BookRepositoryImpl(gh<_i701.BookRemoteDataSource>()),
    );
    gh.factory<_i478.AddManualBook>(
      () => _i478.AddManualBook(gh<_i223.BookRepository>()),
    );
    gh.factory<_i265.GetBookDetail>(
      () => _i265.GetBookDetail(gh<_i223.BookRepository>()),
    );
    gh.factory<_i451.ImportBookFromGoogle>(
      () => _i451.ImportBookFromGoogle(gh<_i223.BookRepository>()),
    );
    gh.factory<_i1069.LookupBookByIsbn>(
      () => _i1069.LookupBookByIsbn(gh<_i223.BookRepository>()),
    );
    gh.factory<_i791.SearchBooks>(
      () => _i791.SearchBooks(gh<_i223.BookRepository>()),
    );
    gh.factory<_i442.FollowCubit>(
      () => _i442.FollowCubit(
        gh<_i334.ListFollowers>(),
        gh<_i427.ListFollowing>(),
        gh<_i242.FollowUser>(),
        gh<_i488.UnfollowUser>(),
      ),
    );
    gh.lazySingleton<_i769.SessionRepository>(
      () => _i431.SessionRepositoryImpl(
        gh<_i871.SessionRemoteDataSource>(),
        gh<_i677.SessionLocalDataSource>(),
      ),
    );
    gh.factory<_i380.BookSearchBloc>(
      () => _i380.BookSearchBloc(
        gh<_i791.SearchBooks>(),
        gh<_i451.ImportBookFromGoogle>(),
      ),
    );
    gh.factory<_i437.GetAllBadges>(
      () => _i437.GetAllBadges(gh<_i787.BadgeRepository>()),
    );
    gh.factory<_i310.CompleteOnboarding>(
      () => _i310.CompleteOnboarding(gh<_i202.AuthRepository>()),
    );
    gh.factory<_i1052.GetCurrentUser>(
      () => _i1052.GetCurrentUser(gh<_i202.AuthRepository>()),
    );
    gh.factory<_i189.Login>(() => _i189.Login(gh<_i202.AuthRepository>()));
    gh.factory<_i60.LoginWithGoogle>(
      () => _i60.LoginWithGoogle(gh<_i202.AuthRepository>()),
    );
    gh.factory<_i542.Logout>(() => _i542.Logout(gh<_i202.AuthRepository>()));
    gh.factory<_i461.Register>(
      () => _i461.Register(gh<_i202.AuthRepository>()),
    );
    gh.factory<_i362.UpdateProfile>(
      () => _i362.UpdateProfile(gh<_i202.AuthRepository>()),
    );
    gh.factory<_i423.OnboardingCubit>(
      () => _i423.OnboardingCubit(
        gh<_i362.UpdateProfile>(),
        gh<_i310.CompleteOnboarding>(),
      ),
    );
    gh.factory<_i481.LeaderboardCubit>(
      () => _i481.LeaderboardCubit(gh<_i643.GetLeaderboard>()),
    );
    gh.factory<_i704.ProfileCubit>(
      () => _i704.ProfileCubit(
        gh<_i1052.GetCurrentUser>(),
        gh<_i884.GetStatsSummary>(),
        gh<_i437.GetAllBadges>(),
        gh<_i815.GetFollowCounts>(),
      ),
    );
    gh.factory<_i945.BadgeCubit>(
      () => _i945.BadgeCubit(gh<_i437.GetAllBadges>()),
    );
    gh.factory<_i428.StatsCubit>(
      () =>
          _i428.StatsCubit(gh<_i884.GetStatsSummary>(), gh<_i485.GetHeatmap>()),
    );
    gh.factory<_i108.GetFeed>(() => _i108.GetFeed(gh<_i674.FeedRepository>()));
    gh.factory<_i52.GetSocialFeed>(
      () => _i52.GetSocialFeed(gh<_i674.FeedRepository>()),
    );
    gh.lazySingleton<_i180.ShelfRepository>(
      () => _i841.ShelfRepositoryImpl(
        gh<_i192.ShelfRemoteDataSource>(),
        gh<_i223.BookRepository>(),
      ),
    );
    gh.factory<_i759.GetSessionHistory>(
      () => _i759.GetSessionHistory(gh<_i769.SessionRepository>()),
    );
    gh.factory<_i621.SubmitSession>(
      () => _i621.SubmitSession(gh<_i769.SessionRepository>()),
    );
    gh.lazySingleton<_i558.PushNotificationService>(
      () => _i558.PushNotificationService(
        gh<_i618.FirebaseMessagingGateway>(),
        gh<_i856.RegisterDevice>(),
        gh<_i567.NotificationNavigator>(),
      ),
    );
    gh.factory<_i498.FeedCubit>(
      () => _i498.FeedCubit(
        gh<_i52.GetSocialFeed>(),
        gh<_i1052.GetCurrentUser>(),
      ),
    );
    gh.factory<_i928.SessionTimerCubit>(
      () => _i928.SessionTimerCubit(gh<_i621.SubmitSession>()),
    );
    gh.lazySingleton<_i948.AuthCubit>(
      () => _i948.AuthCubit(
        gh<_i189.Login>(),
        gh<_i60.LoginWithGoogle>(),
        gh<_i461.Register>(),
        gh<_i1052.GetCurrentUser>(),
        gh<_i542.Logout>(),
        gh<_i558.PushNotificationService>(),
      ),
    );
    gh.factory<_i640.AddToShelf>(
      () => _i640.AddToShelf(gh<_i180.ShelfRepository>()),
    );
    gh.factory<_i156.ListShelf>(
      () => _i156.ListShelf(gh<_i180.ShelfRepository>()),
    );
    gh.factory<_i88.UpdateShelfStatus>(
      () => _i88.UpdateShelfStatus(gh<_i180.ShelfRepository>()),
    );
    gh.factory<_i1054.HomeCubit>(
      () => _i1054.HomeCubit(
        gh<_i1052.GetCurrentUser>(),
        gh<_i485.GetHeatmap>(),
        gh<_i156.ListShelf>(),
      ),
    );
    gh.lazySingleton<_i387.SessionExpiredHandler>(
      () => sessionExpiredHandlerModule.sessionExpiredHandler(
        gh<_i948.AuthCubit>(),
      ),
    );
    gh.lazySingleton<_i584.GoRouter>(
      () => appRouterModule.goRouter(
        gh<_i839.SecureTokenStorage>(),
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
        gh<_i948.AuthCubit>(),
      ),
    );
    gh.factory<_i1011.ShelfCubit>(
      () => _i1011.ShelfCubit(
        gh<_i156.ListShelf>(),
        gh<_i88.UpdateShelfStatus>(),
      ),
    );
    return this;
  }
}

class _$SharedPreferencesModule extends _i390.SharedPreferencesModule {}

class _$GoogleSignInModule extends _i63.GoogleSignInModule {}

class _$NavigatorKeyModule extends _i683.NavigatorKeyModule {}

class _$FirebaseMessagingModule extends _i618.FirebaseMessagingModule {}

class _$ConnectivityModule extends _i104.ConnectivityModule {}

class _$DioClientModule extends _i873.DioClientModule {}

class _$SessionExpiredHandlerModule extends _i948.SessionExpiredHandlerModule {}

class _$AppRouterModule extends _i683.AppRouterModule {}
