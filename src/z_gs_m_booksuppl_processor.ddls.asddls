@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection for Booking Supplement Entity'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
define view entity Z_GS_M_BOOKSUPPL_PROCESSOR as projection on ZR_GS_M_BOOKSUPPPL
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking: redirected to parent Z_GS_M_BOOKING_PROCESSOR,
    _Product,
    _ProductText,
    _Travel: redirected to Z_GS_M_TRAVEL_PROCESSOR
}
