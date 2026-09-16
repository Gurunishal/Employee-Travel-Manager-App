@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement as grandchild'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZR_GS_M_BOOKSUPPPL as select from /dmo/booksuppl_m
association to parent ZR_GS_M_BOOKING as _Booking on
    $projection.TravelId = _Booking.TravelId and
    $projection.BookingId = _Booking.BookingId
association [1..1] to ZR_GS_M_TRAVEL as _Travel on
    $projection.TravelId = _Travel.TravelId
association[0..1] to /DMO/I_Supplement as _Product on
    $projection.SupplementId = _Product.SupplementID
association[0..*] to /DMO/I_SupplementText as _ProductText on
    $projection.SupplementId = _ProductText.SupplementID

{
    key travel_id as TravelId,
    key booking_id as BookingId,
    key booking_supplement_id as BookingSupplementId,
    supplement_id as SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    _Product,
    _ProductText,
    _Travel,
    _Booking
}
