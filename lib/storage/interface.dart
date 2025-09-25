/// Platform-agnostic contract for persisting encoded repository payloads.
///
/// Implementations are expected to store values under a stable [key] derived
/// from the entity type and operate asynchronously so they can be swapped for
/// different backends in tests.
abstract class DraftModeStorage {
  /// Reads the raw JSON string for the repository or returns `null` when no
  /// value is present.
  Future<String?> read();

  /// Persists the provided encoded JSON payload.
  Future<void> write(String value);

  /// Removes any stored payload.
  Future<void> delete();

  /// Unique identifier used by the backing store for this repository.
  String get key;
}
