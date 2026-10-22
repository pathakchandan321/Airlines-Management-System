import { LightningElement } from 'lwc';
import searchFlights from '@salesforce/apex/FlightSearchController.searchFlights';

const CITIES = [
    'Delhi', 'Mumbai', 'Pune', 'Bengaluru',
    'Kolkata', 'Chennai', 'Hyderabad'
];

export default class FlightSearch extends LightningElement {
    source;
    destination;
    results = [];
    errorMessage;
    hasSearched = false;

    columns = [
        { label: 'Schedule', fieldName: 'scheduleName' },
        { label: 'Flight', fieldName: 'flightName' },
        { label: 'From', fieldName: 'source' },
        { label: 'To', fieldName: 'destination' },
        { label: 'Departure', fieldName: 'departure', type: 'date',
            typeAttributes: { year: 'numeric', month: 'short', day: '2-digit',
                hour: '2-digit', minute: '2-digit' } },
        { label: 'Arrival', fieldName: 'arrival', type: 'date',
            typeAttributes: { year: 'numeric', month: 'short', day: '2-digit',
                hour: '2-digit', minute: '2-digit' } },
        { label: 'Active bookings', fieldName: 'activeBookings', type: 'number' }
    ];

    get cityOptions() {
        return CITIES.map(city => ({ label: city, value: city }));
    }

    get hasResults() {
        return this.results.length > 0;
    }

    handleSourceChange(event) {
        this.source = event.detail.value;
    }

    handleDestinationChange(event) {
        this.destination = event.detail.value;
    }

    async handleSearch() {
        this.errorMessage = undefined;
        this.hasSearched = true;
        try {
            this.results = await searchFlights({
                source: this.source,
                destination: this.destination
            });
        } catch (error) {
            this.results = [];
            this.errorMessage = error?.body?.message || 'Unable to search flights.';
        }
    }
}
