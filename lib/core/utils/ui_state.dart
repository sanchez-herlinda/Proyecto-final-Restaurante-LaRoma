enum UIStateStatus { initial, loading, success, error }

class UIState<T> {
  final UIStateStatus status;
  final T? data;
  final String? errorMessage;

  UIState._({required this.status, this.data, this.errorMessage});

  factory UIState.initial() => UIState._(status: UIStateStatus.initial);
  factory UIState.loading() => UIState._(status: UIStateStatus.loading);
  factory UIState.success(T data) =>
      UIState._(status: UIStateStatus.success, data: data);
  factory UIState.error(String message) =>
      UIState._(status: UIStateStatus.error, errorMessage: message);

  bool get isInitial => status == UIStateStatus.initial;
  bool get isLoading => status == UIStateStatus.loading;
  bool get isSuccess => status == UIStateStatus.success;
  bool get isError => status == UIStateStatus.error;
}
