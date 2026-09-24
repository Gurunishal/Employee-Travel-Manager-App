@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Entity as first child'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZR_GS_M_BOOKING as select from /dmo/booking_m
composition[1..*] of ZR_GS_M_BOOKSUPPPL as _BookSuppl
association to parent ZR_GS_M_TRAVEL as _Travel on
    $projection.TravelId = _Travel.TravelId
association[1] to /DMO/I_Customer as _Customer on
    $projection.CustomerId = _Customer.CustomerID
association[1] to /DMO/I_Carrier as _Carrier on
    $projection.CarrierId = _Carrier.AirlineID
association[1] to /DMO/I_Connection as _Connection on
    $projection.CarrierId = _Connection.AirlineID and
    $projection.ConnectionId = _Connection.ConnectionID
association[1] to I_Currency as _Currency on
    $projection.CurrencyCode = _Currency.Currency
association[1] to /DMO/I_Booking_Status_VH as _BookStatus on
    $projection.BookingStatus = _BookStatus.BookingStatus

{
    key travel_id as TravelId,
    key booking_id as BookingId,
    booking_date as BookingDate,
    @ObjectModel.text.element: [ 'CustomerName' ]
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Customer',
                     entity.element: 'CustomerID'
                 }
    ]
    customer_id as CustomerId,
    _Customer.LastName as CustomerName,
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Carrier',
                     entity.element: 'AirlineID'
                 }
    ]
    @ObjectModel.text.element: [ 'AirlineName' ]
    carrier_id as CarrierId,
    _Carrier.Name as AirlineName,
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Connection',
                     entity.element: 'ConnectionID',
                     additionalBinding: [
                        {
                            element: 'AirlineID',
                            localElement: 'CarrierID'
                        }
                     ]
                     
                 }
    ]
    connection_id as ConnectionId,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Booking_Status_VH',
                     entity.element: 'BookingStatus'
                     
                 }
    ]
    currency_code as CurrencyCode,
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: 'I_Currency',
                     entity.element: 'Currency'
                     
                 }
    ]
    booking_status as BookingStatus,
    _BookStatus._Text[ Language = $session.system_language].Text as BookingStatusText,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    _Customer,
    _Carrier,
    _Connection,
    _Currency,
    _BookStatus,
    _BookSuppl,
    --expose the Parent
    _Travel
}
