@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection for Booking Entity'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
define view entity Z_GS_M_BOOKING_PROCESSOR as projection on ZR_GS_M_BOOKING
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _BookStatus,
    _BookSuppl: redirected to composition child Z_GS_M_BOOKSUPPL_PROCESSOR,
    _Carrier,
    _Connection,
    _Currency,
    _Customer,
    _Travel: redirected to parent Z_GS_M_TRAVEL_PROCESSOR
}
