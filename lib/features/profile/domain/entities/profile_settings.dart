class ProfileSettings {
  final bool pushNotifications;
  final bool smsAlerts;
  final bool emailUpdates;
  final String language;

  const ProfileSettings({
    this.pushNotifications = true,
    this.smsAlerts = true,
    this.emailUpdates = false,
    this.language = 'English',
  });

  ProfileSettings copyWith({
    bool? pushNotifications,
    bool? smsAlerts,
    bool? emailUpdates,
    String? language,
  }) {
    return ProfileSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      language: language ?? this.language,
    );
  }
}
