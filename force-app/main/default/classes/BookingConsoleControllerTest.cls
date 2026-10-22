@IsTest
private class BookingConsoleControllerTest {
    @TestSetup
    static void createData() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'CONSOLE-101',
            Flight_Company__c = 'SkyManage'
        );
        insert flight;

        Passenger__c passenger = new Passenger__c(
            First_Name__c = 'Console',
            Last_Name__c = 'Passenger',
            Email_Address__c = 'console.passenger@example.com'
        );
        insert passenger;

        insert new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '1A',
            Booking_Status__c = 'Confirmed',
            Amount__c = 3000
        );
    }

    @IsTest
    static void loadsBookingRows() {
        Test.startTest();
        List<BookingConsoleController.BookingRow> rows =
            BookingConsoleController.getRecentBookings();
        Test.stopTest();

        System.assertEquals(1, rows.size());
        System.assertEquals('CONSOLE-101', rows[0].flightName);
        System.assertEquals('Console Passenger', rows[0].passengerName);
        System.assertEquals('Confirmed', rows[0].status);
    }

    @IsTest
    static void cancelsBookingRow() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];

        Test.startTest();
        BookingConsoleController.BookingRow row =
            BookingConsoleController.cancelBooking(booking.Id);
        Test.stopTest();

        System.assertEquals('Cancelled', row.status);
    }
}
