import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/build_context_extension.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_listener.dart';
import '../../../shelf/domain/usecases/add_to_shelf.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/lookup_book_by_isbn.dart';
import '../widgets/book_result_card.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key, this.closeOnAdd = false});

  /// When true, a successful "Add to shelf" closes this page (popping `true`)
  /// instead of resuming the camera for another scan — used by onboarding,
  /// where scanning is a one-and-done step, not a cataloging session.
  final bool closeOnAdd;

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;
    final isbn = capture.barcodes.first.rawValue;
    if (isbn == null) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    final result = await getIt<LookupBookByIsbn>().call(isbn);
    if (!mounted) return;

    await result.fold(
      (failure) async {
        context.showFailureSnackBar(failure);
        setState(() => _isProcessing = false);
        await _controller.start();
      },
      (book) => _showResultSheet(book),
    );
  }

  Future<void> _showResultSheet(Book book) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (sheetContext) => _ScanResultSheet(book: book),
    );

    if (!mounted) return;

    if (added == true && widget.closeOnAdd) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _isProcessing = false);
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Text(
              l10n.scanIsbnGuide,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanResultSheet extends StatelessWidget {
  const _ScanResultSheet({required this.book});

  final Book book;

  Future<void> _addToShelf(BuildContext context) async {
    final l10n = context.l10n;
    final result = await getIt<AddToShelf>().call(bookId: book.id);
    if (!context.mounted) return;
    Navigator.of(context).pop(result.isRight());
    result.fold(
      (failure) => context.showFailureSnackBar(failure),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bookAddedToShelf)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BookResultCard(book: book),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addToShelf(context),
                child: Text(l10n.addToShelf),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
