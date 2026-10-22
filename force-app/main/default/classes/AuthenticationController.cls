public with sharing class AuthenticationController {

    public class UserInfoResult {
        @AuraEnabled public String userId;
        @AuraEnabled public String userName;
        @AuraEnabled public String userEmail;
        @AuraEnabled public String userRole;
        @AuraEnabled public Boolean isAdmin;
    }

    @AuraEnabled
    public static UserInfoResult getCurrentUser() {
        Id currentUserId = System.UserInfo.getUserId();
        User currentUser = [
            SELECT Id, Name, Email, Profile.Name, UserRole.Name
            FROM User
            WHERE Id = :currentUserId
            LIMIT 1
        ];

        UserInfoResult info = new UserInfoResult();
        info.userId = currentUser.Id;
        info.userName = currentUser.Name;
        info.userEmail = currentUser.Email;
        info.userRole = currentUser.UserRole?.Name;
        info.isAdmin = isUserAdmin(currentUser);

        return info;
    }

    @AuraEnabled
    public static Map<String, Object> registerUser(
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
                result.put('message', 'All fields are required');
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

            // Create Contact record to store user info
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Description = 'User Type: ' + userType
            );
            insert newContact;

            result.put('success', true);
            result.put('message', 'Registration successful! Please contact admin for access.');
            result.put('contactId', newContact.Id);

        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Error during registration: ' + e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Map<String, Object> loginUser(String email, String password) {
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
            String userType = userContact.Description?.contains('Admin') ? 'admin' : 'user';

            result.put('success', true);
            result.put('message', 'Login successful!');
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

    @AuraEnabled(cacheable=true)
    public static Boolean checkUserPermission() {
        Id currentUserId = System.UserInfo.getUserId();
        User currentUser = [
            SELECT Id, Profile.Name
            FROM User
            WHERE Id = :currentUserId
            LIMIT 1
        ];

        return isUserAdmin(currentUser);
    }

    private static Boolean isUserAdmin(User usr) {
        // Check if user has admin profile or permission set
        String profileName = usr.Profile.Name.toLowerCase();
        return profileName.contains('admin') || profileName.contains('system');
    }

    @AuraEnabled
    public static String getRedirectUrl(String userType) {
        if (userType == 'admin') {
            return '/lightning/n/Admin_Dashboard';
        } else {
            return '/lightning/n/User_Dashboard';
        }
    }
}
