namespace Vjeko.Demos.Rental;

interface "DEMO Rental Object Type"
{
    procedure Initialize(No: Code[20]);
    procedure ValidateRequirements();
    procedure AssignDefaults(var RentalLine: Record "DEMO Rental Line");
    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line");
    procedure ChangeUnitOfMeasure(var RentalLine: Record "DEMO Rental Line");
    procedure ChangeUnitOfMeasure(var RentalJournalLine: Record "DEMO Rental Journal Line");
    procedure AcceptsClientType(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean;
    procedure AcceptsClientType(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean;
    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean;
    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean;
    procedure AllowsLocationCode(var RentalLine: Record "DEMO Rental Line"): Boolean;
    procedure AllowsLocationCode(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean;
}
