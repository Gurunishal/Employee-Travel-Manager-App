@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Request Root Entity'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define root view entity ZR_GS_M_TRAVEL as select from /dmo/travel_m
composition[1..*] of ZR_GS_M_BOOKING as _Booking
association[1] to /DMO/I_Agency as _Agency on
    $projection.AgencyId = _Agency.AgencyID
association[1] to /DMO/I_Customer as _Customer on
    $projection.CustomerId = _Customer.CustomerID
association[1] to I_Currency as _Currency on
    $projection.CurrencyCode = _Currency.Currency
association[1] to /DMO/I_Overall_Status_VH as _OverallStatus on
    $projection.OverallStatus = _OverallStatus.OverallStatus
{
    @ObjectModel.text.element: [ 'Description' ]
    key travel_id as TravelId,
    @ObjectModel.text.element: [ 'AgencyName' ]
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Agency',
                     entity.element: 'AgencyID'
                 }
    ]
    agency_id as AgencyId,
    _Agency.Name as AgencyName,
    @ObjectModel.text.element: [ 'CustomerName' ]
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Customer',
                     entity.element: 'CustomerID'
                 }
    ]
    customer_id as CustomerId,
    concat(_Customer.LastName, concat(' ', _Customer.FirstName)) as CustomerName,
    begin_date as BeginDate,
    end_date as EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    booking_fee as BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    total_price as TotalPrice,
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: 'I_Currency',
                     entity.element: 'Currency'
                 }
    ]
    currency_code as CurrencyCode,
    description as Description,
    @Consumption.valueHelpDefinition: [
                 {
                     entity.name: '/DMO/I_Overall_Status_VH',
                     entity.element: 'OverallStatus'
                 }
    ]
    @ObjectModel.text.element: [ 'StatusText' ]
    overall_status as OverallStatus,
    _OverallStatus._Text[Language = $session.system_language].Text as StatusText,
    case overall_status 
        when 'O' then 2
        when 'A' then 3
        when 'X' then 1
        else 0
        end as Stat,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    --expose the associations
    _Agency,
    _Customer,
    _Currency,
    _OverallStatus,
    --expose the composition child
    _Booking
}
