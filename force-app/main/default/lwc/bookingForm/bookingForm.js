import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createBooking from '@salesforce/apex/BookingWorkflowController.createBooking';

export default class BookingForm extends LightningElement {
    @api scheduleId;

    @track currentStep = 1; // 1: Passenger Details, 2: Seat Selection, 3: Payment, 4: Confirmation
    @track bookingData = {
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        seatNumber: '',
        amount: 5000,
        paymentMethod: 'credit_card'
    };

    @track confirmationDetails = null;

    isSaving = false;
    errorMessage = '';

    // Payment method options
    get paymentMethodOptions() {
        return [
            { label: 'Credit Card', value: 'credit_card' },
            { label: 'Debit Card', value: 'debit_card' },
            { label: 'UPI', value: 'upi' },
            { label: 'Net Banking', value: 'net_banking' }
        ];
    }

    // Step indicators
    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }
    get isStep4() { return this.currentStep === 4; }

    get step1Class() {
        return this.currentStep >= 1 ? 'slds-path__item slds-is-complete' : 'slds-path__item';
    }
    get step2Class() {
        return this.currentStep >= 2 ? 'slds-path__item slds-is-complete' : 'slds-path__item';
    }
    get step3Class() {
        return this.currentStep >= 3 ? 'slds-path__item slds-is-complete' : 'slds-path__item';
    }
    get step4Class() {
        return this.currentStep === 4 ? 'slds-path__item slds-is-complete slds-is-current' : 'slds-path__item';
    }

    // Field change handlers
    handleFirstNameChange(event) {
        this.bookingData.firstName = event.target.value;
        this.errorMessage = '';
    }

    handleLastNameChange(event) {
        this.bookingData.lastName = event.target.value;
        this.errorMessage = '';
    }

    handleEmailChange(event) {
        this.bookingData.email = event.target.value;
        this.errorMessage = '';
    }

    handlePhoneChange(event) {
        this.bookingData.phone = event.target.value;
        this.errorMessage = '';
    }

    handleSeatSelect(event) {
        this.bookingData.seatNumber = event.detail.seatNumber;
    }

    handlePaymentMethodChange(event) {
        this.bookingData.paymentMethod = event.detail.value;
    }

    // Navigation handlers
    handleNext() {
        if (this.validateCurrentStep()) {
            this.currentStep++;
            this.errorMessage = '';
        }
    }

    handlePrevious() {
        if (this.currentStep > 1) {
            this.currentStep--;
            this.errorMessage = '';
        }
    }

    validateCurrentStep() {
        if (this.currentStep === 1) {
            // Validate passenger details
            if (!this.bookingData.firstName || !this.bookingData.lastName ||
                !this.bookingData.email || !this.bookingData.phone) {
                this.errorMessage = 'Please fill all required passenger details';
                return false;
            }

            // Validate email format
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(this.bookingData.email)) {
                this.errorMessage = 'Please enter a valid email address';
                return false;
            }

            // Validate phone format
            const phoneRegex = /^[0-9]{10}$/;
            if (!phoneRegex.test(this.bookingData.phone.replace(/\D/g, ''))) {
                this.errorMessage = 'Please enter a valid 10-digit phone number';
                return false;
            }
        }

        if (this.currentStep === 2) {
            // Validate seat selection
            if (!this.bookingData.seatNumber) {
                this.errorMessage = 'Please select a seat';
                return false;
            }
        }

        return true;
    }

    async handlePayment() {
        if (!this.bookingData.paymentMethod) {
            this.errorMessage = 'Please select a payment method';
            return;
        }

        this.isSaving = true;
        this.errorMessage = '';

        try {
            // Simulate payment processing
            await this.processPayment();

            // Create booking after successful payment
            const result = await createBooking({
                scheduleId: this.scheduleId,
                flightId: null,
                firstName: this.bookingData.firstName,
                lastName: this.bookingData.lastName,
                email: this.bookingData.email,
                phone: this.bookingData.phone,
                seatNumber: this.bookingData.seatNumber,
                amount: this.bookingData.amount
            });

            // Store confirmation details
            this.confirmationDetails = {
                pnr: result.pnr || this.generatePNR(),
                bookingId: result.bookingId || result.id,
                passengerName: `${this.bookingData.firstName} ${this.bookingData.lastName}`,
                email: this.bookingData.email,
                phone: this.bookingData.phone,
                seatNumber: this.bookingData.seatNumber,
                amount: this.bookingData.amount,
                paymentMethod: this.getPaymentMethodLabel(),
                bookingDate: new Date().toLocaleDateString('en-IN', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                })
            };

            // Move to confirmation step
            this.currentStep = 4;

            this.showToast('Success', 'Booking confirmed successfully!', 'success');

            // Notify parent component
            this.dispatchEvent(new CustomEvent('bookingcomplete', {
                detail: { booking: this.confirmationDetails }
            }));

        } catch (error) {
            this.errorMessage = 'Payment failed: ' + (error.body?.message || error.message || 'Unknown error');
            this.showToast('Error', this.errorMessage, 'error');
        } finally {
            this.isSaving = false;
        }
    }

    processPayment() {
        // Simulate payment processing delay
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve({ success: true, transactionId: 'TXN' + Date.now() });
            }, 2000);
        });
    }

    generatePNR() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let pnr = '';
        for (let i = 0; i < 6; i++) {
            pnr += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return pnr;
    }

    getPaymentMethodLabel() {
        const option = this.paymentMethodOptions.find(opt => opt.value === this.bookingData.paymentMethod);
        return option ? option.label : this.bookingData.paymentMethod;
    }

    handleNewBooking() {
        // Reset form
        this.currentStep = 1;
        this.bookingData = {
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            seatNumber: '',
            amount: 5000,
            paymentMethod: 'credit_card'
        };
        this.confirmationDetails = null;
        this.errorMessage = '';

        // Notify parent to refresh
        this.dispatchEvent(new CustomEvent('newbooking'));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
