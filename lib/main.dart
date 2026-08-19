import 'package:flutter/material.dart';

import 'package:crud_application/contact.dart';
import 'package:crud_application/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ContactsHomePage(),
    );
  }
}

// It is a StatefulWidget because the contacts list can change when:
// 1. contacts are loaded from the backend,
// 2. a new contact is added,
// 3. an existing contact is updated,
// 4. a contact is deleted.
class ContactsHomePage extends StatefulWidget {
  const ContactsHomePage({super.key});

  @override
  State<ContactsHomePage> createState() => _ContactsHomePageState();
}

// This State class stores the changing data for ContactsHomePage.
// Anything that should update the screen is stored here.
class _ContactsHomePageState extends State<ContactsHomePage> {
  // ContactApi contains the HTTP functions that communicate with the backend
  final ContactApi contactApi = ContactApi();

  // This list stores all contacts received from the backend which is a Contact object created from JSON data.
  List<Contact> contacts = [];

  //loading spinner
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    //loads data from the backend when the app starts
    _loadContacts();
  }

  // This function gets all contacts from the backend.
  // It is async because HTTP requests take time to complete. (await)
  Future<void> _loadContacts() async {
    // setState() tells Flutter that change happened and UI should rebuild shows loading spinner
    setState(() => isLoading = true);

    try {
      // Calls GET /contacts
      contacts = await contactApi.getAllContacts();
    } catch (error) {
      // mounted checks that the screen still exists before using context.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // This function deletes one contact using its database id (from contact_id column)
  Future<void> _deleteContact(int id) async {
    try {
      await contactApi.delete(id);

      // After deleting, load the contacts again so the UI shows fresh data.
      await _loadContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted successfully!')),
        );
      }
    } catch (error) {
      // If the delete request fails, error message shown.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // This function opens a dialog box with a contact form.
  // If contact is empty, the form is used to add a new contact.
  // If contact has a value, the form is used to edit that existing contact.
  Future<void> _showContactForm({Contact? contact}) async {
    // formKey is used to check validity of forms.
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: contact?.name ?? '');
    final emailController = TextEditingController(text: contact?.email ?? '');
    final phoneController = TextEditingController(
      text: contact?.phoneNumber ?? '',
    );

    // showDialog opens a popup above the current page.
    // It returns true when the contact is saved and false/null when cancelled.
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    // validator checks whether the name field is valid.
                    // null = valid field.
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    // This makes sure the email field is not empty.
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    // This makes sure the phone number field is not empty.
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                // validate() runs all 'validator' functions in the form.
                // If any field is invalid, stop here and do not save.
                if (!formKey.currentState!.validate()) return;

                // Create a Contact object using the text entered by the user.
                // trim() removes unnecessary spaces from the start and end.
                final newContact = Contact(
                  id: contact?.id,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                );

                // If contact is null, this is a new contact, so call POST /contacts.
                // Otherwise, this is an existing contact, so call PUT /contacts/:id.
                if (contact == null) {
                  await contactApi.create(newContact);
                } else {
                  await contactApi.update(newContact);
                }

                if (context.mounted) {
                  // Close the dialog and return true to say the save succeeded.
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // // Controllers use memory, so  should be disposed when no longer needed. to prevent memory leaks after the dialog is closed.
    // nameController.dispose();
    // emailController.dispose();
    // phoneController.dispose();

    // If the dialog = true, a contact added/updated. reloads to show latest db
    if (saved == true) {
      await _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // The body changes depending on the current state:
      // 1. If data is loading, show a spinner.
      // 2. If there are no contacts, show an empty message.
      // 3. If contacts exist, show them in a scrollable list.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts yet!\nTap + to create one',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadContacts,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];

                  // This letter is shown inside the circle avatar.
                  // If the contact name is empty, show '?' instead.
                  final firstLetter = contact.name.isEmpty
                      ? '?'
                      : contact.name[0].toUpperCase();

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          firstLetter,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(
                        '${contact.email}\n${contact.phoneNumber}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showContactForm(contact: contact),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final id = contact.id;

                              // Only delete if the contact has an id from the database.
                              // New unsaved contacts would have a null id.
                              if (id != null) {
                                _deleteContact(id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        // Opens the form without passing a contact, so it creates a new contact.
        onPressed: () => _showContactForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }
}
