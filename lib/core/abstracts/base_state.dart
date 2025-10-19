/// Immutable base state interface (optional – for consistency).
abstract class ViewState {
  const ViewState();
}

/// Generic simple status wrapper you can reuse if you like.
enum LoadStatus { idle, loading, success, error }
