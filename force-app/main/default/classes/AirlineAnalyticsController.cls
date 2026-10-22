public with sharing class AirlineAnalyticsController {
    public class Metrics {
        @AuraEnabled public Integer totalBookings;
        @AuraEnabled public Integer activeBookings;
        @AuraEnabled public Integer cancelledBookings;
        @AuraEnabled public Decimal activeRevenue;
        @AuraEnabled public Integer totalPayments;
        @AuraEnabled public List<StatusMetric> statusMetrics;
        @AuraEnabled public List<FlightMetric> flightMetrics;

        public Metrics() {
            totalBookings = 0;
            activeBookings = 0;
            cancelledBookings = 0;
            activeRevenue = 0;
            totalPayments = 0;
            statusMetrics = new List<StatusMetric>();
            flightMetrics = new List<FlightMetric>();
        }
    }

    public class StatusMetric {
        @AuraEnabled public String label;
        @AuraEnabled public Integer count;

        public StatusMetric(String label, Integer count) {
            this.label = label;
            this.count = count;
        }
    }

    public class FlightMetric {
        @AuraEnabled public String label;
        @AuraEnabled public Integer bookings;
        @AuraEnabled public Decimal revenue;

        public FlightMetric(String label, Integer bookings, Decimal revenue) {
            this.label = label;
            this.bookings = bookings;
            this.revenue = revenue == null ? 0 : revenue;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Metrics getMetrics() {
        Metrics metrics = new Metrics();
        for (AggregateResult row : [
            SELECT Booking_Status__c status, COUNT(Id) bookingCount, SUM(Amount__c) revenue
            FROM Booking__c
            GROUP BY Booking_Status__c
        ]) {
            Integer count = (Integer) row.get('bookingCount');
            String status = (String) row.get('status');
            metrics.statusMetrics.add(new StatusMetric(status, count));
            metrics.totalBookings += count;
            if (status == 'Cancelled') {
                metrics.cancelledBookings = count;
            } else {
                metrics.activeBookings += count;
                Decimal revenue = (Decimal) row.get('revenue');
                if (revenue != null) {
                    metrics.activeRevenue += revenue;
                }
            }
        }

        for (AggregateResult row : [
            SELECT Flight__r.Flight_Name__c flightName, COUNT(Id) bookingCount, SUM(Amount__c) revenue
            FROM Booking__c
            WHERE Booking_Status__c != 'Cancelled'
            GROUP BY Flight__r.Flight_Name__c
            ORDER BY COUNT(Id) DESC
            LIMIT 10
        ]) {
            metrics.flightMetrics.add(new FlightMetric(
                (String) row.get('flightName'),
                (Integer) row.get('bookingCount'),
                (Decimal) row.get('revenue')
            ));
        }

        metrics.totalPayments = [SELECT COUNT() FROM Payment__c];
        return metrics;
    }
}
