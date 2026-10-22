@IsTest
private class BookingCancellationServiceTest {
    @TestSetup
    static void createData() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'CANCEL-101',
            Flight_Company__c = 'SkyManage'
        );
        insert flight;

        Passenger__c passenger = new Passenger__c(
            First_Name__c = 'Cancellation',
            Last_Name__c = 'Test',
            Email_Address__c = 'cancellation.test@example.com'
        );
        insert passenger;

        insert new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '20A',
            Booking_Status__c = 'Confirmed'
        );
    }

    @IsTest
    static void cancelsActiveBookingAndReleasesSeat() {
        Booking__c booking = [
            SELECT Id, Booking_Status__c
            FROM Booking__c
            LIMIT 1
        ];

        Test.startTest();
        Booking__c cancelled = BookingCancellationService.cancelBooking(booking.Id);
        Test.stopTest();

        System.assertEquals('Cancelled', cancelled.Booking_Status__c);

        Booking__c stored = [
            SELECT Booking_Status__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];
        System.assertEquals('Cancelled', stored.Booking_Status__c);
    }

    @IsTest
    static void repeatedCancellationIsIdempotent() {
        Booking__c booking = [
            SELECT Id
            FROM Booking__c
            LIMIT 1
        ];

        BookingCancellationService.cancelBooking(booking.Id);

        Test.startTest();
        Booking__c cancelledAgain = BookingCancellationService.cancelBooking(booking.Id);
        Test.stopTest();

        System.assertEquals('Cancelled', cancelledAgain.Booking_Status__c);
    }

    @IsTest
    static void rejectsMissingBooking() {
        try {
            BookingCancellationService.cancelBooking(null);
            System.assert(false, 'Expected a missing-booking error.');
        } catch (AuraHandledException exceptionThrown) {
            System.assertNotEquals(null, exceptionThrown);
        }
    }
}
