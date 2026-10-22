import { LightningElement, api, wire } from 'lwc';
import getBookedSeats from '@salesforce/apex/BookingWorkflowController.getBookedSeats';

// Generate seat layout: 10 rows, 6 seats per row (A-F)
const ROWS = 10;
const SEAT_LETTERS = ['A', 'B', 'C', 'D', 'E', 'F'];

export default class SeatMap extends LightningElement {
    @api scheduleId;
    @api flightId;
    unavailableSeats = [];
    selectedSeat = '';
    isLoading = true;

    connectedCallback() {
        // Use scheduleId if available, otherwise use flightId
        const id = this.scheduleId || this.flightId;
        if (id) {
            this.loadBookedSeatsData(id);
        }
    }

    @wire(getBookedSeats, { flightId: '$flightId' })
    wiredBookedSeats({ data, error }) {
        if (data) {
            this.unavailableSeats = data.map(seat => seat.toUpperCase());
            this.isLoading = false;
        } else if (error) {
            console.error('Error loading booked seats:', error);
            this.unavailableSeats = [];
            this.isLoading = false;
        }
    }

    async loadBookedSeatsData(id) {
        try {
            const data = await getBookedSeats({ flightId: id });
            this.unavailableSeats = data ? data.map(seat => seat.toUpperCase()) : [];
        } catch (error) {
            console.error('Error loading booked seats:', error);
            this.unavailableSeats = [];
        } finally {
            this.isLoading = false;
        }
    }

    get seatRows() {
        const rows = [];
        for (let i = 1; i <= ROWS; i++) {
            const seats = SEAT_LETTERS.map(letter => {
                const seatName = `${i}${letter}`;
                const isBooked = this.unavailableSeats.includes(seatName);
                const isSelected = this.selectedSeat === seatName;

                return {
                    name: seatName,
                    disabled: isBooked,
                    title: isBooked ? 'Already booked' : `Select seat ${seatName}`,
                    cssClass: this.getSeatClass(isBooked, isSelected),
                    iconName: isBooked ? 'utility:close' : isSelected ? 'utility:check' : 'utility:emoji'
                };
            });

            rows.push({
                rowNumber: i,
                leftSeats: seats.slice(0, 3), // A, B, C
                rightSeats: seats.slice(3, 6) // D, E, F
            });
        }
        return rows;
    }

    getSeatClass(isBooked, isSelected) {
        if (isBooked) return 'seat seat-booked';
        if (isSelected) return 'seat seat-selected';
        return 'seat seat-available';
    }

    get availableCount() {
        const totalSeats = ROWS * SEAT_LETTERS.length;
        return totalSeats - this.unavailableSeats.length;
    }

    get bookedCount() {
        return this.unavailableSeats.length;
    }

    handleSeatClick(event) {
        const seatName = event.currentTarget.dataset.seat;
        const isBooked = this.unavailableSeats.includes(seatName);

        if (isBooked) {
            return; // Can't select booked seat
        }

        // Toggle selection
        if (this.selectedSeat === seatName) {
            this.selectedSeat = '';
        } else {
            this.selectedSeat = seatName;
        }

        // Notify parent component
        this.dispatchEvent(new CustomEvent('seatselect', {
            detail: { seatNumber: this.selectedSeat }
        }));
    }
}
