class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role; // e.g., Farmer, Agronomist, Buyer, Admin
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
  });

  // Optional: add copyWith, fromSchema, etc. as needed later
}
