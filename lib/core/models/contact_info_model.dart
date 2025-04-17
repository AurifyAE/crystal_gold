class ContactModel {
  final String id;
  final String userName;
  final String companyName;
  final String address;
  final String email;
  final int contact;
  final int whatsapp;

  ContactModel({
    required this.id,
    required this.userName,
    required this.companyName,
    required this.address,
    required this.email,
    required this.contact,
    required this.whatsapp,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['_id'] ?? '',
      userName: json['userName'] ?? '',
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? 0,
      whatsapp: json['whatsapp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userName': userName,
      'companyName': companyName,
      'address': address,
      'email': email,
      'contact': contact,
      'whatsapp': whatsapp,
    };
  }
}