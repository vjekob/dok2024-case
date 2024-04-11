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
}
