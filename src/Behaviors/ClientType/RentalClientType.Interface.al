namespace Vjeko.Demos.Rental;

interface "DEMO Rental Client Type"
{
    procedure Initialize(No: Code[20]);
    procedure ValidateRequirements();
    procedure HasConstraints(): Boolean;
    procedure ValidateConstraints(): Boolean;
    procedure AssignDefaults(var RentalHeader: Record "DEMO Rental Header");
}
