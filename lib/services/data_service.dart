import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _nameKey = 'name';
  static const String _bioKey = 'bio';
  static const String _emailKey = 'email';
  static const String _pronounsKey = 'pronouns';
  static const String _urlKey = 'url';
  static const String _userDomainKey = 'userDomain';

  // Valid emails that can login
  static const List<String> validEmails = [
    'karim@coach.com',
    'karim@player.com',
    'zeyad@coach.com',
    'zeyad@player.com',
  ];

  // Name
  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Zeyad Waleed';
  }

  static Future<void> setName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
  }

  // Bio
  static Future<String> getBio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bioKey) ??
        "Talented goalkeeper currently playing for Al Ahly, one of Egypt's most prestigious football clubs. Born and raised in Cairo.";
  }

  static Future<void> setBio(String newBio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bioKey, newBio);
  }

  // Email
  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? 'ZOZ@sportofolio.com';
  }

  static Future<void> setEmail(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, newEmail);
  }

  // Pronouns
  static Future<String> getPronouns() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pronounsKey) ?? 'he/him';
  }

  static Future<void> setPronouns(String newPronouns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pronounsKey, newPronouns);
  }

  // URL
  static Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey) ?? 'http://sportofolio/profile/{id}';
  }

  static Future<void> setUrl(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, newUrl);
  }

  // User Domain (coach.com or player.com)
  static Future<String?> getUserDomain() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDomainKey);
  }

  static Future<void> setUserDomain(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDomainKey, domain);
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    return validEmails.contains(email);
  }

  // Add email to valid emails list
  static Future<void> addEmail(String newEmail) async {
    // In a real app, this would be handled by a backend
    // For now, we just store it locally
    if (!validEmails.contains(newEmail)) {
      // This would typically be sent to a backend
    }
  }

  // Check if user is authorized
  static Future<bool> isAuthorized() async {
    final domain = await getUserDomain();
    return domain != null && (domain == 'coach.com' || domain == 'player.com');
  }
}




