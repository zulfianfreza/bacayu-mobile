import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_localizer.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../shelf/domain/entities/user_book.dart';
import '../../../shelf/domain/usecases/list_shelf.dart';

/// Reuses `shelf`'s `ListShelf` usecase (filtered to `reading`) — no
/// separate query/logic here.
class BookPickerBottomSheet extends StatefulWidget {
  const BookPickerBottomSheet({super.key});

  @override
  State<BookPickerBottomSheet> createState() => _BookPickerBottomSheetState();
}

class _BookPickerBottomSheetState extends State<BookPickerBottomSheet> {
  late final Future<Either<Failure, List<UserBook>>> _future =
      getIt<ListShelf>().call(status: ShelfStatus.reading);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.whatAreYouReading, style: AppTypography.heading),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: FutureBuilder<Either<Failure, List<UserBook>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return snapshot.data!.fold(
                    (failure) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(failure.localizedMessage(context)),
                    ),
                    (books) => books.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.noReadingBooks,
                              style: AppTypography.body,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final userBook = books[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  child: SizedBox(
                                    width: 40,
                                    height: 56,
                                    child: userBook.book.coverUrl == null
                                        ? Container(color: AppColors.tangerine50)
                                        : Image.network(
                                            userBook.book.coverUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: AppColors.tangerine50,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  userBook.book.title,
                                  style: AppTypography.subheading,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    Navigator.of(context).pop(userBook),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
