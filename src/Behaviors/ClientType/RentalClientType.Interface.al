namespace Vjeko.Demos.Rental;

interface "DEMO Rental Client Type"
{
    procedure Initialize(No: Code[20]);
    procedure ValidateRequirements();
    procedure ValidatePostingRequirements();
    procedure HasConstraints(): Boolean;
    procedure ValidateConstraints(): Boolean;
    procedure AssignDefaults(var RentalHeader: Record "DEMO Rental Header");
    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line");
    procedure AllowChangePostingGroupMandatory(): Boolean;
    procedure CanChangeClientName(var RentalHeader: Record "DEMO Rental Header"): Boolean;
    procedure CanChangeClientName(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean;
    procedure CanChangeEMail(var RentalHeader: Record "DEMO Rental Header"): Boolean;
    procedure CanChangeEMail(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean;
    procedure CanChangeGenBusPostingGroup(var RentalHeader: Record "DEMO Rental Header"): Boolean;
    procedure CanChangeGenBusPostingGroup(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean;
    procedure AcceptsObjectType(var RentalLine: Record "DEMO Rental Line"): Boolean;
    procedure AcceptsObjectType(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean;
    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"): Boolean;
    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean;
}
