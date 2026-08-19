class Contact {
  // It is nullable because a new contact will not have an id before it is saved.
  final int? id;
  final String name;
  final String email;
  final String phoneNumber;

  // Constructor to create a Contact object.
  const Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  // Converts JSON into a Contact object from  Node.js API
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['contact_id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
    );
  }

  // Converts a Contact object into JSON to send to the Node.js API.
  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone_number': phoneNumber};
  }
}
