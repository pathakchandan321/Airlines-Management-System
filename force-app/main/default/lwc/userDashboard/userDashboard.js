import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchFlights from '@salesforce/apex/FlightSearchController.searchFlights';

const CITIES = [
    'Delhi', 'Mumbai', 'Pune', 'Bengaluru',
    'Kolkata', 'Chennai', 'Hyderabad'
];

export default class UserDashboard extends LightningElement {
    @track source = '';
    @track destination = '';
    @track results = [];
    @track errorMessage = '';
    @track hasSearched = false;
    @track selectedScheduleId = null;
    @track isSearching = false;

    get cityOptions() {
        return CITIES.map(city => ({ label: city, value: city }));
    }

    get hasResults() {
        return this.results.length > 0;
    }

    handleSourceChange(event) {
        this.source = event.detail.value;
        this.errorMessage = '';
    }

    handleDestinationChange(event) {
        this.destination = event.detail.value;
        this.errorMessage = '';
    }

    async handleSearch() {
        // Validation
        if (!this.source || !this.destination) {
            this.errorMessage = 'Please select both departure and destination cities';
            return;
        }

        if (this.source === this.destination) {
            this.errorMessage = 'Departure and destination cities cannot be the same';
            return;
        }

        this.errorMessage = '';
        this.hasSearched = true;
        this.isSearching = true;
        this.selectedScheduleId = null;

        try {
            const rawResults = await searchFlights({
                source: this.source,
                destination: this.destination
            });

            // Format results
            this.results = rawResults.map(result => ({
                scheduleId: result.scheduleId,
                scheduleName: result.scheduleName,
                flightName: result.flightName,
                source: result.source,
                destination: result.destination,
                departure: result.departure,
                arrival: result.arrival,
                departureFormatted: this.formatDateTime(result.departure),
                arrivalFormatted: this.formatDateTime(result.arrival),
                activeBookings: result.activeBookings,
                availableSeats: this.calculateAvailableSeats(result.activeBookings)
            }));

            if (this.results.length === 0) {
                this.errorMessage = 'No flights found for this route. Try different cities.';
            }

        } catch (error) {
            this.results = [];
            this.errorMessage = 'Unable to search flights: ' + (error?.body?.message || error.message || 'Please try again.');
            console.error('Flight search error:', error);
        } finally {
            this.isSearching = false;
        }
    }

    handleClear() {
        this.source = '';
        this.destination = '';
        this.results = [];
        this.errorMessage = '';
        this.hasSearched = false;
        this.selectedScheduleId = null;
    }

    handleBookFlight(event) {
        const scheduleId = event.target.dataset.scheduleId;
        this.selectedScheduleId = scheduleId;

        // Show message
        this.showToast('Info', 'Booking form will load here', 'info');
    }

    formatDateTime(dateTimeValue) {
        if (!dateTimeValue) return '';

        try {
            const date = new Date(dateTimeValue);
            const options = {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                hour12: true
            };
            return date.toLocaleString('en-US', options);
        } catch (e) {
            return dateTimeValue;
        }
    }

    calculateAvailableSeats(activeBookings) {
        const totalSeats = 180;
        const bookedSeats = activeBookings || 0;
        return totalSeats - bookedSeats;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
