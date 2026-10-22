@IsTest
private class AirlineAnalyticsControllerTest {
    @IsTest
    static void summarizesBookingsAndPayments() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'AN-901',
            Flight_Company__c = 'SkyManage'
        );
        insert flight;

        Passenger__c passenger = new Passenger__c(
            First_Name__c = 'Analytics',
            Last_Name__c = 'Passenger',
            Email_Address__c = 'analytics@example.com'
        );
        insert passenger;

        insert new List<Booking__c>{
            new Booking__c(
                Flight__c = flight.Id,
                Passenger__c = passenger.Id,
                Seat_Number__c = '2A',
                Booking_Status__c = 'Confirmed',
                Amount__c = 1200
            ),
            new Booking__c(
                Flight__c = flight.Id,
                Passenger__c = passenger.Id,
                Seat_Number__c = '2B',
                Booking_Status__c = 'Cancelled',
                Amount__c = 800
            )
        };

        Test.startTest();
        AirlineAnalyticsController.Metrics metrics =
            AirlineAnalyticsController.getMetrics();
        Test.stopTest();

        System.assertEquals(2, metrics.totalBookings);
        System.assertEquals(1, metrics.activeBookings);
        System.assertEquals(1, metrics.cancelledBookings);
        System.assertEquals(1200, metrics.activeRevenue);
        System.assertEquals(0, metrics.totalPayments);
        System.assertEquals(2, metrics.statusMetrics.size());
        System.assertEquals(1, metrics.flightMetrics.size());
        System.assertEquals('AN-901', metrics.flightMetrics[0].label);
    }
}
