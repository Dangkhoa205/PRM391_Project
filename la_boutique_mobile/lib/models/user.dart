class UserModel {
  final String id;
  final String? accountId;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final DateTime? birthDate;
  final String? gender; // 'MALE', 'FEMALE', 'OTHER'
  final String? avatarUrl;
  final String address;
  final String? roleName;
  /// Cờ BE trả ở /profiles/me: hồ sơ đã đủ thông tin (SĐT, địa chỉ...) chưa.
  /// Dùng cho Nudge nhắc hoàn thiện hồ sơ (nhất là tài khoản Google thuần).
  final bool profileCompleted;

  UserModel({
    required this.id,
    this.accountId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    this.birthDate,
    this.gender,
    this.avatarUrl,
    required this.address,
    this.roleName,
    this.profileCompleted = false,
  });

  // Alias for backward compatibility with existing views
  String get name => fullName.isNotEmpty ? fullName : username;

  String get genderDisplay {
    if (gender == 'MALE') return 'Nam';
    if (gender == 'FEMALE') return 'Nữ';
    if (gender == 'OTHER') return 'Khác';
    return 'Chưa cập nhật';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String().split('T').first,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'address': address,
      'roleName': roleName,
      'profileCompleted': profileCompleted,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedBirthDate;
    if (json['birthDate'] != null) {
      try {
        parsedBirthDate = DateTime.parse(json['birthDate'] as String);
      } catch (_) {}
    }

    final uname = (json['username'] as String?) ??
        (json['email'] as String? ?? '').split('@').first;
    final fName = (json['fullName'] as String?) ?? (json['name'] as String?) ?? uname;

    return UserModel(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString(),
      username: uname,
      email: (json['email'] as String?) ?? '',
      fullName: fName,
      phone: (json['phone'] as String?) ?? '',
      birthDate: parsedBirthDate,
      gender: json['gender'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      address: (json['address'] as String?) ?? '',
      roleName: json['roleName'] as String?,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? accountId,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? avatarUrl,
    String? address,
    String? roleName,
    bool? profileCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      roleName: roleName ?? this.roleName,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}
