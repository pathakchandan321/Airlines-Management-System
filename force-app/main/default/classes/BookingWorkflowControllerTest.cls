@IsTest
private class BookingWorkflowControllerTest {
    @TestSetup
    static void createData() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'BOOK-101',
            Flight_Company__c = 'SkyManage'
        );
        insert flight;
    }

    @IsTest
    static void createsBookingAndMockPayment() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];

        Test.startTest();
        BookingWorkflowController.BookingResult result =
            BookingWorkflowController.createBooking(
                null, flight.Id, 'Book', 'Passenger', 'book@example.com',
                '9999999999', '22A', 4500
            );
        Test.stopTest();

        System.assertNotEquals(null, result.bookingId);
        System.assertNotEquals(null, result.paymentId);
        System.assertEquals('Confirmed', result.status);
        System.assertEquals('22A', result.seatNumber);
        System.assertEquals(1, [
            SELECT COUNT()
            FROM Payment__c
            WHERE Booking__c = :result.bookingId
        ]);
    }

    @IsTest
    static void rejectsIncompleteBooking() {
        try {
            BookingWorkflowController.createBooking(
                null, null, 'Book', 'Passenger', 'book@example.com',
                null, '22A', 4500
            );
            System.assert(false, 'Expected booking validation error.');
        } catch (AuraHandledException exceptionThrown) {
            System.assertNotEquals(null, exceptionThrown);
        }
    }

    @IsTest
    static void loadsAvailableFlights() {
        Test.startTest();
        List<BookingWorkflowController.FlightOption> options =
            BookingWorkflowController.getAvailableFlights();
        Test.stopTest();

        System.assertEquals(1, options.size());
        System.assertEquals('BOOK-101 - SkyManage', options[0].label);
    }

    @IsTest
    static void loadsBookedSeatsOnlyForActiveBookings() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        Passenger__c passenger = new Passenger__c(
            First_Name__c = 'Seat',
            Last_Name__c = 'Test',
            Email_Address__c = 'seat@example.com'
        );
        insert passenger;
        insert new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '3b',
            Booking_Status__c = 'Confirmed',
            Amount__c = 1000
        );

        Test.startTest();
        List<String> seats = BookingWorkflowController.getBookedSeats(flight.Id);
        Test.stopTest();

        System.assertEquals(1, seats.size());
        System.assertEquals('3B', seats[0]);
    }
}
