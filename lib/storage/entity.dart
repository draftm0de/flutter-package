abstract class DraftModeEntityStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
  String get key;
}
