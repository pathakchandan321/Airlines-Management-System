import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AdminDashboard extends NavigationMixin(LightningElement) {
    @track currentUser = null;
    @track isLoading = true;

    connectedCallback() {
        this.checkAuthentication();
    }

    checkAuthentication() {
        try {
            const userDataString = sessionStorage.getItem('currentUser');

            if (!userDataString) {
                // No user logged in, redirect to login
                this.redirectToLogin();
                return;
            }

            const userData = JSON.parse(userDataString);

            // Check if user is admin
            if (!userData.isAdmin) {
                this.showToast('Access Denied', 'You do not have permission to access Admin Dashboard', 'error');
                this.redirectToUserDashboard();
                return;
            }

            this.currentUser = userData;
            this.isLoading = false;

        } catch (error) {
            console.error('Authentication check failed:', error);
            this.redirectToLogin();
        }
    }

    handleLogout() {
        // Clear session
        sessionStorage.removeItem('currentUser');

        this.showToast('Success', 'Logged out successfully', 'success');

        // Redirect to login page
        setTimeout(() => {
            this.redirectToLogin();
        }, 500);
    }

    redirectToLogin() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Login_Page'
            }
        });
    }

    redirectToUserDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'User_Dashboard'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    get userName() {
        return this.currentUser?.userName || 'Admin';
    }

    get userEmail() {
        return this.currentUser?.userEmail || '';
    }
}
