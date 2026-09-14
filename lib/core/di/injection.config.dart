// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mobile/core/localization/locale_cubit.dart' as _i390;
import 'package:mobile/core/network/dio_client.dart' as _i873;
import 'package:mobile/core/router/app_router.dart' as _i683;
import 'package:mobile/core/storage/app_database.dart' as _i141;
import 'package:mobile/core/storage/secure_token_storage.dart' as _i839;
import 'package:mobile/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i1044;
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart'
    as _i950;
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i202;
import 'package:mobile/features/auth/domain/usecases/get_current_user.dart'
    as _i1052;
import 'package:mobile/features/auth/domain/usecases/login.dart' as _i189;
import 'package:mobile/features/auth/domain/usecases/logout.dart' as _i542;
import 'package:mobile/features/auth/domain/usecases/register.dart' as _i461;
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart'
    as _i948;
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
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final dioClientModule = _$DioClientModule();
    final appRouterModule = _$AppRouterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i141.AppDatabase>(() => _i141.AppDatabase());
    gh.lazySingleton<_i839.SecureTokenStorage>(
      () => _i839.SecureTokenStorage(),
    );
    gh.lazySingleton<_i390.LocaleCubit>(
      () => _i390.LocaleCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioClientModule.dio(gh<_i839.SecureTokenStorage>()),
    );
    gh.lazySingleton<_i583.GoRouter>(
      () => appRouterModule.goRouter(gh<_i839.SecureTokenStorage>()),
    );
    gh.factory<_i1044.AuthRemoteDataSource>(
      () => _i1044.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i701.BookRemoteDataSource>(
      () => _i701.BookRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i192.ShelfRemoteDataSource>(
      () => _i192.ShelfRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i202.AuthRepository>(
      () => _i950.AuthRepositoryImpl(
        gh<_i1044.AuthRemoteDataSource>(),
        gh<_i839.SecureTokenStorage>(),
      ),
    );
    gh.factory<_i1052.GetCurrentUser>(
      () => _i1052.GetCurrentUser(gh<_i202.AuthRepository>()),
    );
    gh.factory<_i189.Login>(() => _i189.Login(gh<_i202.AuthRepository>()));
    gh.factory<_i542.Logout>(() => _i542.Logout(gh<_i202.AuthRepository>()));
    gh.factory<_i461.Register>(
      () => _i461.Register(gh<_i202.AuthRepository>()),
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
    gh.factory<_i948.AuthCubit>(
      () => _i948.AuthCubit(
        gh<_i189.Login>(),
        gh<_i461.Register>(),
        gh<_i1052.GetCurrentUser>(),
        gh<_i542.Logout>(),
      ),
    );
    gh.factory<_i380.BookSearchBloc>(
      () => _i380.BookSearchBloc(
        gh<_i791.SearchBooks>(),
        gh<_i451.ImportBookFromGoogle>(),
      ),
    );
    gh.lazySingleton<_i180.ShelfRepository>(
      () => _i841.ShelfRepositoryImpl(
        gh<_i192.ShelfRemoteDataSource>(),
        gh<_i223.BookRepository>(),
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

class _$DioClientModule extends _i873.DioClientModule {}

class _$AppRouterModule extends _i683.AppRouterModule {}
