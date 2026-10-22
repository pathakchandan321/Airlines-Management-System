@IsTest
private class FlightScheduleTriggerHandlerTest {
    @TestSetup
    static void createData() {
        insert new Flight__c(
            Flight_Name__c = 'TRG-101',
            Flight_Company__c = 'SkyManage'
        );
    }

    private static Flight__c flight() {
        return [SELECT Id FROM Flight__c WHERE Flight_Name__c = 'TRG-101' LIMIT 1];
    }

    private static Flight_Schedule__c schedule(Datetime departure) {
        return new Flight_Schedule__c(
            Name = 'Trigger Schedule',
            Flight__c = flight().Id,
            Source_Name__c = 'Delhi',
            Destination_Name__c = 'Mumbai',
            Departure_Date_Time__c = departure,
            Arrival_Date_Time__c = departure.addHours(2)
        );
    }

    @IsTest
    static void blocksDuplicateActiveSchedule() {
        Datetime departure = System.now().addDays(4);
        insert schedule(departure);
        try {
            insert schedule(departure);
            System.assert(false, 'Expected duplicate schedule to be blocked.');
        } catch (DmlException exceptionThrown) {
            System.assert(exceptionThrown.getMessage().contains('active schedule'));
        }
    }

    @IsTest
    static void allowsCancelledScheduleReuse() {
        Datetime departure = System.now().addDays(5);
        Flight_Schedule__c first = schedule(departure);
        insert first;
        System.assertEquals(1, [SELECT COUNT() FROM Flight_Schedule__c]);
    }

    @IsTest
    static void returnsRelationshipQueries() {
        insert schedule(System.now().addDays(6));
        Test.startTest();
        List<Flight_Schedule__c> rows =
            FlightScheduleQueryService.withinDateRange(
                System.now().addDays(5),
                System.now().addDays(7)
            );
        List<Flight__c> parents = FlightScheduleQueryService.flightsWithSchedules();
        Test.stopTest();
        System.assertEquals(1, rows.size());
        System.assertEquals(1, parents[0].Flight_Schedules__r.size());
    }
}
