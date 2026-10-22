@IsTest
private class FlightSearchControllerTest {
    @TestSetup
    static void createData() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'SEARCH-101',
            Flight_Company__c = 'SkyManage'
        );
        insert flight;

        insert new Flight_Schedule__c(
            Name = 'Delhi to Mumbai Search',
            Flight__c = flight.Id,
            Source_Name__c = 'Delhi',
            Destination_Name__c = 'Mumbai',
            Departure_Date_Time__c = System.now().addDays(2),
            Arrival_Date_Time__c = System.now().addDays(2).addHours(2)
        );
    }

    @IsTest
    static void searchesUpcomingRoute() {
        Test.startTest();
        List<FlightSearchController.FlightRow> rows =
            FlightSearchController.searchFlights('Delhi', 'Mumbai');
        Test.stopTest();

        System.assertEquals(1, rows.size());
        System.assertEquals('SEARCH-101', rows[0].flightName);
        System.assertEquals('Delhi', rows[0].source);
        System.assertEquals(0, rows[0].activeBookings);
    }

    @IsTest
    static void rejectsBlankRoute() {
        try {
            FlightSearchController.searchFlights('', 'Mumbai');
            System.assert(false, 'Expected a route validation error.');
        } catch (AuraHandledException exceptionThrown) {
            System.assertNotEquals(null, exceptionThrown);
        }
    }
}
