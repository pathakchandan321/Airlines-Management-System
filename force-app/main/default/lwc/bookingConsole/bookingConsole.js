import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRecentBookings from '@salesforce/apex/BookingConsoleController.getRecentBookings';
import cancelBooking from '@salesforce/apex/BookingConsoleController.cancelBooking';

const ACTIONS = [{ label: 'Cancel booking', name: 'cancel' }];

export default class BookingConsole extends LightningElement {
    columns = [
        { label: 'PNR', fieldName: 'pnr' },
        { label: 'Flight', fieldName: 'flightName' },
        { label: 'Passenger', fieldName: 'passengerName' },
        { label: 'Seat', fieldName: 'seatNumber' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Amount', fieldName: 'amount', type: 'currency' },
        { type: 'action', typeAttributes: { rowActions: ACTIONS } }
    ];

    bookings = [];
    errorMessage;
    wiredBookings;

    @wire(getRecentBookings)
    loadBookings(result) {
        this.wiredBookings = result;
        if (result.data) {
            this.bookings = result.data;
            this.errorMessage = undefined;
        } else if (result.error) {
            this.errorMessage = this.getErrorMessage(result.error);
        }
    }

    async handleRowAction(event) {
        if (event.detail.action.name !== 'cancel') {
            return;
        }

        try {
            await cancelBooking({ bookingId: event.detail.row.id });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Booking cancelled',
                message: `${event.detail.row.pnr} was cancelled successfully.`,
                variant: 'success'
            }));
            await refreshApex(this.wiredBookings);
        } catch (error) {
            this.errorMessage = this.getErrorMessage(error);
        }
    }

    async handleRefresh() {
        await refreshApex(this.wiredBookings);
    }

    getErrorMessage(error) {
        return error?.body?.message || 'Unable to load or update bookings.';
    }
}
