class Business {
  final String id; 
  final String name;
  final String location;
  final String phone;

  Business({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
  });

  factory Business.fromMap(Map<String, dynamic> map, {String? idPrefix, int? idx}) {
    final rawName = (map['biz_name'] ?? map['name'] ?? '').toString().trim();
    final rawLocation = (map['bss_location'] ?? map['location'] ?? '').toString().trim();
    final rawPhone = (map['contct_no'] ?? map['phone'] ?? '').toString().trim();

    if (rawName.isEmpty) throw FormatException('Missing business name');
    if (rawLocation.isEmpty) throw FormatException('Missing location');
    if (!_isValidPhone(rawPhone)) throw FormatException('Invalid phone format');

    final id = idPrefix != null && idx != null ? '$idPrefix-$idx' : DateTime.now().millisecondsSinceEpoch.toString();

    return Business(
      id: id,
      name: rawName,
      location: rawLocation,
      phone: rawPhone,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'location': location,
        'phone': phone,
      };

  static bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 6;
  }
}
