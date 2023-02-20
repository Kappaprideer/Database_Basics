USE u_jsmolka

CREATE ROLE Admin
GRANT ALL PRIVILEGES TO Admin

CREATE ROLE Employee

GRANT SELECT ON ActiveDiscounts TO Employee
GRANT SELECT ON AvailableCourses TO Employee
GRANT SELECT ON CurrentCurrencies TO Employee
GRANT SELECT ON CurrentMenu TO Employee
GRANT SELECT ON CurrentSeafoodMenu TO Employee
GRANT SELECT ON CustomerDiscountChoice TO Employee
GRANT SELECT ON NotConfirmedReservations TO Employee
GRANT SELECT ON TakeawayOrdersToBeFulfilled TO Employee
GRANT SELECT ON GetMenuFrom TO Employee
GRANT SELECT ON GetSeafoodMenuFrom TO Employee
GRANT EXECUTE ON AcceptDelivery TO Employee
GRANT EXECUTE ON AddCompanyCustomer TO Employee
GRANT EXECUTE ON AddIndividualCustomer TO Employee
GRANT EXECUTE ON AddToStock TO Employee
GRANT EXECUTE ON ConfirmOrder TO Employee
GRANT EXECUTE ON ConfirmPayment TO Employee
GRANT EXECUTE ON ConfirmReservation TO Employee
GRANT EXECUTE ON ConvertToPLN TO Employee
GRANT EXECUTE ON CourseInMenu TO Employee
GRANT EXECUTE ON CourseInStock TO Employee
GRANT EXECUTE ON GetDiscount TO Employee
GRANT EXECUTE ON GetSeats TO Employee
GRANT EXECUTE ON getUnitPrice TO Employee
GRANT EXECUTE ON IsTableFree TO Employee
GRANT EXECUTE ON PlaceOrder TO Employee
GRANT EXECUTE ON PlaceOrderSeafood TO Employee
GRANT EXECUTE ON MakeReservation TO Employee
GRANT EXECUTE ON DropDiscount  TO Employee

CREATE ROLE Manager
GRANT SELECT ON ActiveDiscounts TO Manager
GRANT SELECT ON AvailableCourses TO Manager
GRANT SELECT ON CourseOrderedUnitsLastYearMonthReport TO Manager
GRANT SELECT ON CourseOrderedUnitsLastYearWeekReport TO Manager
GRANT SELECT ON CourseOrderedUnitsThisMonthReport TO Manager
GRANT SELECT ON CurrentCurrencies TO Manager
GRANT SELECT ON CurrentMenu TO Manager
GRANT SELECT ON CurrentSeafoodMenu TO Manager
GRANT SELECT ON CustomerDiscountChoice TO Manager
GRANT SELECT ON CustomersOrdersStatistics TO Manager
GRANT SELECT ON CustomersReservationsStatistics TO Manager
GRANT SELECT ON NotConfirmedReservations TO Manager
GRANT SELECT ON OrdersLastYearMonthReport TO Manager
GRANT SELECT ON OrdersLastYearWeekReport TO Manager
GRANT SELECT ON ReservationsAndReservedTablesLastYearMonthReport TO Manager
GRANT SELECT ON ReservationsAndReservedTablesLastYearWeekReport TO Manager
GRANT SELECT ON ReservationsThisMonthReport TO Manager
GRANT SELECT ON ReservedTablesThisMonthReport TO Manager
GRANT SELECT ON TablesReservationsYearMonthReport TO Manager
GRANT SELECT ON TablesReservationsYearWeekReport TO Manager
GRANT SELECT ON TakeawayOrdersToBeFulfilled TO Manager
GRANT SELECT ON GetMenuFrom TO Manager
GRANT SELECT ON GetSeafoodMenuFrom TO Manager
GRANT EXECUTE ON AcceptDelivery TO Manager
GRANT EXECUTE ON AddCompanyCustomer TO Manager
GRANT EXECUTE ON AddCourse TO Manager
GRANT EXECUTE ON AddCourseCategory TO Manager
GRANT EXECUTE ON AddCurrencyPosition TO Manager
GRANT EXECUTE ON AddEmployee TO Manager
GRANT EXECUTE ON AddIndividualCustomer TO Manager
GRANT EXECUTE ON AddTable TO Manager
GRANT EXECUTE ON AddToMenu TO Manager
GRANT EXECUTE ON AddToSeafoodMenu TO Manager
GRANT EXECUTE ON AddToStock TO Manager
GRANT EXECUTE ON ChangeCourseUnitPrice TO Manager
GRANT EXECUTE ON ConfirmOrder TO Manager
GRANT EXECUTE ON ConfirmPayment TO Manager
GRANT EXECUTE ON ConfirmReservation TO Manager
GRANT EXECUTE ON ConvertToPLN TO Manager
GRANT EXECUTE ON CourseInMenu TO Manager
GRANT EXECUTE ON CourseInStock TO Manager
GRANT EXECUTE ON DenyInvoicePermission TO Manager
GRANT EXECUTE ON GrantInvoicePermission TO Manager
GRANT EXECUTE ON GetDiscount TO Manager
GRANT EXECUTE ON GetSeats TO Manager
GRANT EXECUTE ON getUnitPrice TO Manager
GRANT EXECUTE ON GrantReportPermission TO Manager
GRANT EXECUTE ON DenyReportPermission TO Manager
GRANT EXECUTE ON IsTableFree TO Manager
GRANT EXECUTE ON PlaceOrder TO Manager
GRANT EXECUTE ON PlaceOrderSeafood TO Manager
GRANT EXECUTE ON DenyReservationPermission TO Manager
GRANT EXECUTE ON GrantOrderPermission TO Manager
GRANT EXECUTE ON GrantReservationPermission TO Manager
GRANT EXECUTE ON DenyOrderPermission TO Manager
GRANT EXECUTE ON MakeReservation TO Manager
GRANT EXECUTE ON DropDiscount TO Manager






