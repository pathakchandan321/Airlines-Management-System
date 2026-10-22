public with sharing class BookingWorkflowController {
    public class FlightOption {
        @AuraEnabled public Id value;
        @AuraEnabled public String label;

        public FlightOption(Flight__c flight) {
            value = flight.Id;
            label = flight.Flight_Name__c + ' - ' + flight.Flight_Company__c;
        }
    }

    public class BookingResult {
        @AuraEnabled public Id bookingId;
        @AuraEnabled public String pnr;
        @AuraEnabled public String status;
        @AuraEnabled public String seatNumber;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Id paymentId;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBookedSeats(Id flightId) {
        if (flightId == null) {
            return new List<String>();
        }

        List<String> seats = new List<String>();

        // Query bookings for the flight
        List<Booking__c> bookings = [
            SELECT Seat_Number__c
            FROM Booking__c
            WHERE Flight__c = :flightId
            AND Booking_Status__c != 'Cancelled'
            AND Seat_Number__c != null
        ];

        for (Booking__c booking : bookings) {
            seats.add(booking.Seat_Number__c.trim().toUpperCase());
        }
        return seats;
    }

    @AuraEnabled(cacheable=true)
    public static List<FlightOption> getAvailableFlights() {
        List<FlightOption> options = new List<FlightOption>();
        for (Flight__c flight : [
            SELECT Id, Flight_Name__c, Flight_Company__c
            FROM Flight__c
            ORDER BY Flight_Name__c
            LIMIT 100
        ]) {
            options.add(new FlightOption(flight));
        }
        return options;
    }

    @AuraEnabled
    public static BookingResult createBooking(
        Id scheduleId,
        Id flightId,
        String firstName,
        String lastName,
        String email,
        String phone,
        String seatNumber,
        Decimal amount
    ) {
        // Validate inputs
        if (String.isBlank(firstName) || String.isBlank(lastName) ||
            String.isBlank(email) || String.isBlank(seatNumber) ||
            amount == null || amount <= 0) {
            throw new AuraHandledException(
                'Passenger details, seat and a positive amount are required.'
            );
        }

        // Need either scheduleId or flightId
        if (scheduleId == null && flightId == null) {
            throw new AuraHandledException('Flight schedule or flight is required.');
        }

        Id actualFlightId = flightId;

        // If scheduleId is provided, get the flight from schedule
        if (scheduleId != null) {
            List<Flight_Schedule__c> schedules = [
                SELECT Id, Flight__c
                FROM Flight_Schedule__c
                WHERE Id = :scheduleId
                LIMIT 1
            ];
            if (!schedules.isEmpty()) {
                actualFlightId = schedules[0].Flight__c;
            }
        }

        // Lock the flight record
        Flight__c flight = [
            SELECT Id
            FROM Flight__c
            WHERE Id = :actualFlightId
            LIMIT 1
            FOR UPDATE
        ];

        // Check if seat is already booked
        List<Booking__c> existingBookings = [
            SELECT Id
            FROM Booking__c
            WHERE Flight__c = :actualFlightId
            AND Seat_Number__c = :seatNumber.trim().toUpperCase()
            AND Booking_Status__c != 'Cancelled'
            LIMIT 1
        ];

        if (!existingBookings.isEmpty()) {
            throw new AuraHandledException('Seat ' + seatNumber + ' is already booked. Please select another seat.');
        }

        // Find or create passenger
        Passenger__c passenger;
        List<Passenger__c> matchingPassengers = [
            SELECT Id
            FROM Passenger__c
            WHERE Email_Address__c = :email.trim()
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (matchingPassengers.isEmpty()) {
            passenger = new Passenger__c(
                First_Name__c = firstName.trim(),
                Last_Name__c = lastName.trim(),
                Email_Address__c = email.trim(),
                Phone__c = phone
            );
            insert passenger;
        } else {
            passenger = matchingPassengers[0];
        }

        // Create booking
        Booking__c booking = new Booking__c(
            Flight__c = actualFlightId,
            Passenger__c = passenger.Id,
            Seat_Number__c = seatNumber.trim().toUpperCase(),
            Booking_Status__c = 'Confirmed',
            Amount__c = amount
        );

        insert booking;

        // Reload booking to get auto-generated fields
        booking = [
            SELECT Id, Name, Booking_Status__c, Seat_Number__c, Amount__c
            FROM Booking__c
            WHERE Id = :booking.Id
            LIMIT 1
        ];

        // Process payment
        Payment__c payment = MockPaymentService.processPayment(booking.Id);

        // Build result
        BookingResult result = new BookingResult();
        result.bookingId = booking.Id;
        result.pnr = booking.Name;
        result.status = booking.Booking_Status__c;
        result.seatNumber = booking.Seat_Number__c;
        result.amount = booking.Amount__c;
        result.paymentId = payment.Id;

        return result;
    }
}
