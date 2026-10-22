global class AuthPageController {

    @RemoteAction
    global static Map<String, Object> login(String email, String password) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            // Check if contact exists
            List<Contact> contacts = [
                SELECT Id, FirstName, LastName, Email, Description
                FROM Contact
                WHERE Email = :email
                LIMIT 1
            ];

            if (contacts.isEmpty()) {
                result.put('success', false);
                result.put('message', 'Invalid email or password');
                return result;
            }

            Contact userContact = contacts[0];
            String userType = userContact.Description != null &&
                             userContact.Description.contains('admin') ? 'admin' : 'user';

            result.put('success', true);
            result.put('message', 'Login successful! Redirecting...');
            result.put('userId', userContact.Id);
            result.put('userName', userContact.FirstName + ' ' + userContact.LastName);
            result.put('userEmail', userContact.Email);
            result.put('userType', userType);
            result.put('isAdmin', userType == 'admin');

        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Error during login: ' + e.getMessage());
        }

        return result;
    }

    @RemoteAction
    global static Map<String, Object> register(
        String firstName,
        String lastName,
        String email,
        String phone,
        String password,
        String userType
    ) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            // Validate inputs
            if (String.isBlank(firstName) || String.isBlank(lastName) ||
                String.isBlank(email) || String.isBlank(password)) {
                result.put('success', false);
                result.put('message', 'All required fields must be filled');
                return result;
            }

            // Check if user already exists
            List<Contact> existingContacts = [
                SELECT Id FROM Contact
                WHERE Email = :email
                LIMIT 1
            ];

            if (!existingContacts.isEmpty()) {
                result.put('success', false);
                result.put('message', 'User with this email already exists');
                return result;
            }

            // Create Contact record
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Description = 'User Type: ' + userType
            );
            insert newContact;

            result.put('success', true);
            result.put('message', 'Registration successful! You can now sign in.');
            result.put('contactId', newContact.Id);

        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Registration failed: ' + e.getMessage());
        }

        return result;
    }
}
