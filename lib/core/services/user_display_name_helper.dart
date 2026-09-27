class UserDisplayNameHelper {
  UserDisplayNameHelper._();

  /// Resolves the user's display name according to the strict priority rules:
  /// 1. Explicitly saved Basic Information / profile name
  /// 2. Authenticated Google / Firebase displayName
  /// 3. Email-derived fallback only if available
  /// 4. Returns null if no user name has been provided
  static String? getResolvedDisplayName({
    String? profileName,
    String? authDisplayName,
    String? email,
  }) {
    // 1. Saved profile name from Basic Information
    if (profileName != null && profileName.trim().isNotEmpty) {
      return profileName.trim();
    }

    // 2. Authenticated Google/Firebase displayName
    if (authDisplayName != null && authDisplayName.trim().isNotEmpty) {
      return authDisplayName.trim();
    }

    // 3. Fallback derived from email
    if (email != null && email.trim().isNotEmpty) {
      final emailPrefix = email.trim().split('@').first;
      if (emailPrefix.isNotEmpty) {
        final formatted = emailPrefix
            .replaceAll(RegExp(r'[._-]'), ' ')
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
            .join(' ');
        if (formatted.isNotEmpty) {
          return formatted;
        }
      }
    }

    return null;
  }

  /// Returns the resolved display name or a safe fallback (e.g. 'Patient')
  static String getCurrentUserDisplayName({
    String? profileName,
    String? authDisplayName,
    String? email,
    String fallback = 'Patient',
  }) {
    final resolved = getResolvedDisplayName(
      profileName: profileName,
      authDisplayName: authDisplayName,
      email: email,
    );
    return resolved ?? fallback;
  }

  /// Returns the first name for conversational contexts if full name is provided
  static String getFirstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Patient';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Dynamic Time-based Greeting based on local device time:
  /// 05:00 – 11:59 -> Good Morning
  /// 12:00 – 16:59 -> Good Afternoon
  /// 17:00 – 20:59 -> Good Evening
  /// 21:00 – 04:59 -> Good Night
  static String getTimeBasedGreeting([DateTime? customTime]) {
    final now = customTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Combines dynamic time-based greeting with the real resolved display name
  /// Example:
  /// With name: "Good Afternoon,\nPriya Sharma 👋"
  /// Without name: "Good Afternoon 👋"
  static String getPersonalizedGreeting({
    String? profileName,
    String? authDisplayName,
    String? email,
    DateTime? customTime,
  }) {
    final greeting = getTimeBasedGreeting(customTime);
    final resolved = getResolvedDisplayName(
      profileName: profileName,
      authDisplayName: authDisplayName,
      email: email,
    );

    if (resolved != null && resolved.isNotEmpty) {
      return '$greeting,\n$resolved 👋';
    }
    return '$greeting 👋';
  }
}
