import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Manual debounce `EventTransformer` for `on<Event>(..., transformer:)` —
/// no `bloc_concurrency`/`rxdart` needed. Only the last event in a burst
/// (after [duration] of silence) reaches the handler; earlier ones in the
/// same burst never do, so `blocTest`-style call-count assertions on the
/// underlying repository stay exact.
EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) {
    return events.transform(_DebounceStreamTransformer(duration)).asyncExpand(mapper);
  };
}

class _DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  _DebounceStreamTransformer(this.duration);

  final Duration duration;

  @override
  Stream<T> bind(Stream<T> stream) {
    late final StreamController<T> controller;
    Timer? timer;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (event) {
            timer?.cancel();
            timer = Timer(duration, () => controller.add(event));
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel();
        return subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
