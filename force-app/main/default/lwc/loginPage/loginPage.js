import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loginUser from '@salesforce/apex/AuthenticationController.loginUser';
import registerUser from '@salesforce/apex/AuthenticationController.registerUser';

export default class LoginPage extends NavigationMixin(LightningElement) {
    // Login fields
    email = '';
    password = '';

    // Registration fields
    firstName = '';
    lastName = '';
    phone = '';
    confirmPassword = '';
    userType = 'user';

    // UI state
    showRegistration = false;
    isLoading = false;
    errorMessage = '';
    successMessage = '';

    get userTypeOptions() {
        return [
            { label: 'Regular User', value: 'user' },
            { label: 'Administrator', value: 'admin' }
        ];
    }

    // Login handlers
    handleEmailChange(event) {
        this.email = event.target.value;
        this.errorMessage = '';
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
        this.errorMessage = '';
    }

    // Registration handlers
    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.errorMessage = '';
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.errorMessage = '';
    }

    handlePhoneChange(event) {
        this.phone = event.target.value;
    }

    handleConfirmPasswordChange(event) {
        this.confirmPassword = event.target.value;
        this.errorMessage = '';
    }

    handleUserTypeChange(event) {
        this.userType = event.detail.value;
    }

    toggleRegistration() {
        this.showRegistration = !this.showRegistration;
        this.clearForm();
    }

    clearForm() {
        this.email = '';
        this.password = '';
        this.firstName = '';
        this.lastName = '';
        this.phone = '';
        this.confirmPassword = '';
        this.userType = 'user';
        this.errorMessage = '';
        this.successMessage = '';
    }

    async handleLogin() {
        if (!this.validateLogin()) {
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';
        this.successMessage = '';

        try {
            const result = await loginUser({
                email: this.email,
                password: this.password
            });

            if (result.success) {
                this.successMessage = result.message;

                // Store user info in session storage
                sessionStorage.setItem('currentUser', JSON.stringify({
                    userId: result.userId,
                    userName: result.userName,
                    userEmail: result.userEmail,
                    userType: result.userType,
                    isAdmin: result.isAdmin
                }));

                // Show success toast
                this.showToast('Success', result.message, 'success');

                // Redirect based on user type
                setTimeout(() => {
                    this.redirectUser(result.isAdmin);
                }, 1000);

            } else {
                this.errorMessage = result.message;
            }
        } catch (error) {
            this.errorMessage = 'Login failed: ' + (error.body?.message || error.message);
        } finally {
            this.isLoading = false;
        }
    }

    async handleRegister() {
        if (!this.validateRegistration()) {
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';
        this.successMessage = '';

        try {
            const result = await registerUser({
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                phone: this.phone,
                password: this.password,
                userType: this.userType
            });

            if (result.success) {
                this.successMessage = result.message;
                this.showToast('Success', result.message, 'success');

                // Switch to login form after 2 seconds
                setTimeout(() => {
                    this.toggleRegistration();
                }, 2000);
            } else {
                this.errorMessage = result.message;
            }
        } catch (error) {
            this.errorMessage = 'Registration failed: ' + (error.body?.message || error.message);
        } finally {
            this.isLoading = false;
        }
    }

    validateLogin() {
        if (!this.email || !this.password) {
            this.errorMessage = 'Please enter both email and password';
            return false;
        }

        if (!this.isValidEmail(this.email)) {
            this.errorMessage = 'Please enter a valid email address';
            return false;
        }

        return true;
    }

    validateRegistration() {
        if (!this.firstName || !this.lastName || !this.email || !this.password || !this.confirmPassword) {
            this.errorMessage = 'Please fill all required fields';
            return false;
        }

        if (!this.isValidEmail(this.email)) {
            this.errorMessage = 'Please enter a valid email address';
            return false;
        }

        if (this.password !== this.confirmPassword) {
            this.errorMessage = 'Passwords do not match';
            return false;
        }

        if (this.password.length < 6) {
            this.errorMessage = 'Password must be at least 6 characters long';
            return false;
        }

        return true;
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    redirectUser(isAdmin) {
        if (isAdmin) {
            // Redirect to Admin Dashboard
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'Admin_Dashboard'
                }
            });
        } else {
            // Redirect to User Dashboard
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'User_Dashboard'
                }
            });
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
