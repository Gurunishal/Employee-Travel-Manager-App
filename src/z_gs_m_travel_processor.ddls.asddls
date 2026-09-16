@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity projection layer'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
define root view entity Z_GS_M_TRAVEL_PROCESSOR as projection on ZR_GS_M_TRAVEL
{
    key TravelId,
    AgencyId,
    CustomerId,
    BeginDate,
    EndDate,
    BookingFee,
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    /* Associations */
    _Agency,
    _Booking: redirected to composition child Z_GS_M_BOOKING_PROCESSOR,
    _Currency,
    _Customer,
    _OverallStatus
}
