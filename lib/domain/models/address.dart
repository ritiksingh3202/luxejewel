class Address {
  const Address({
    this.id,
    required this.fullName,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.postalCode,
    this.country = 'US',
    this.isDefault = false,
  });

  final String? id;
  final String fullName;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String postalCode;
  final String country;
  final bool isDefault;

  String get singleLine => [line1, if ((line2 ?? '').isNotEmpty) line2, city, postalCode, country].join(', ');

  Map<String, dynamic> toMap() => {
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'line1': line1.trim(),
        'line2': (line2 ?? '').trim().isEmpty ? null : line2!.trim(),
        'city': city.trim(),
        'postal_code': postalCode.trim(),
        'country': country.trim(),
      };

  factory Address.fromMap(Map<String, dynamic> m) => Address(
        id: m['id'] as String,
        fullName: m['full_name'] as String,
        phone: m['phone'] as String,
        line1: m['line1'] as String,
        line2: m['line2'] as String?,
        city: m['city'] as String,
        postalCode: m['postal_code'] as String,
        country: (m['country'] as String?) ?? 'US',
        isDefault: (m['is_default'] as bool?) ?? false,
      );

  Address copyWith({String? id, bool? isDefault}) => Address(
        id: id ?? this.id,
        fullName: fullName,
        phone: phone,
        line1: line1,
        line2: line2,
        city: city,
        postalCode: postalCode,
        country: country,
        isDefault: isDefault ?? this.isDefault,
      );
}

class UserProfile {
  const UserProfile({required this.id, required this.fullName, this.phone, this.avatarUrl});

  final String id;
  final String fullName;
  final String? phone;
  final String? avatarUrl;

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String,
        fullName: (m['full_name'] as String?) ?? '',
        phone: m['phone'] as String?,
        avatarUrl: m['avatar_url'] as String?,
      );
}
