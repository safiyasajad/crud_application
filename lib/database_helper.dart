import 'dart:convert';

import 'package:flutter/foundation.dart';
// HTTP package used to send requests to the Node.js Express API.
import 'package:http/http.dart' as http;
import 'package:crud_application/contact.dart';

// This class handles all API requests related to contacts.
class ContactApi {
  // Base URL of the Node.js Express server.
  String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }

    return 'http://localhost:5000';
  }

  // Gets all contacts from the backend API.
  Future<List<Contact>> getAllContacts() async {
    final response = await http.get(Uri.parse('$baseUrl/contacts'));

    // when the request fails, throws an error.
    if (response.statusCode != 200) {
      throw Exception('Failed to load contacts');
    }

    // Convert the JSON response into a list of Contact objects.
    final List data = jsonDecode(response.body);
    return data.map((item) => Contact.fromJson(item)).toList();
  }

  // Sends a new contact to the backend API.
  Future<void> create(Contact contact) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save contact');
    }
  }

  // Updates an existing contact in the backend API.
  Future<void> update(Contact contact) async {
    final response = await http.put(
      Uri.parse('$baseUrl/contacts/${contact.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update contact');
    }
  }

  // Deletes a contact from the backend API using its id.
  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/contacts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete contact');
    }
  }
}
