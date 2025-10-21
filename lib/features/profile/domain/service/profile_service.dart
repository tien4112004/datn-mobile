abstract class ProfileService {
  /// Upload avatar image
  /// Returns the URL of the uploaded image
  Future<String> updateAvatar(String imagePath);
}
