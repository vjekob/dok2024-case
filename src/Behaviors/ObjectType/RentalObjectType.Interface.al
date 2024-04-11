namespace Vjeko.Demos.Rental;

interface "DEMO Rental Object Type"
{
    procedure Initialize(No: Code[20]);
    procedure ValidateRequirements();
    procedure AssignDefaults(var RentalLine: Record "DEMO Rental Line");
    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line");
    procedure ChangeUnitOfMeasure(var RentalLine: Record "DEMO Rental Line");
    procedure ChangeUnitOfMeasure(var RentalJournalLine: Record "DEMO Rental Journal Line");
}
