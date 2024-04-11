namespace Vjeko.Demos.Rental;

using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Setup;

codeunit 50032 "DEMO Rental Client - Employee" implements "DEMO Rental Client Type"
{
    var
        _employee: Record Employee;

    procedure Initialize(No: Code[20])
    begin
        _employee.Get(No);
    end;

    procedure ValidateRequirements()
    begin
        _employee.TestField("Privacy Blocked", false);
        _employee.TestField(Status, "Employee Status"::Active);
        _employee.TestField("E-Mail");
    end;

    procedure HasConstraints(): Boolean
    begin
        exit(_employee."Union Code" <> '');
    end;

    procedure ValidateConstraints(): Boolean
    var
        Union: Record Union;
        UnionDoesNotAllowRentalErr: Label 'Unable to proceed with rental for employee %1: the employee belongs to union %2 that does not allow rentals.', Comment = '%1 is employee no., %2 is union code.';
    begin
        _employee.TestField("Union Membership No.");
        Union.Get(_employee."Union Code");
        if Union."DEMO Rental Allowed" = false then
            Error(UnionDoesNotAllowRentalErr, _employee."No.", Union."Code");
    end;

    procedure AssignDefaults(var RentalHeader: Record "DEMO Rental Header")
    var
        RentalSetup: Record "DEMO Rental Setup";
    begin
        RentalSetup.Get();
        RentalHeader."Client Name" := _employee.FullName();
        RentalHeader."E-Mail" := _employee."E-Mail";
        RentalHeader."Gen. Bus. Posting Group" := RentalSetup."Employee Gen.Bus.Posting Group";
    end;

    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line")
    var
        RentalSetup: Record "DEMO Rental Setup";
    begin
        RentalSetup.Get();
        RentalJournalLine."Client Name" := _employee.FullName();
        RentalJournalLine."E-Mail" := _employee."E-Mail";
        RentalJournalLine."Gen. Bus. Posting Group" := RentalSetup."Employee Gen.Bus.Posting Group";
    end;

    procedure AllowChangePostingGroupMandatory(): Boolean
    begin
        exit(false);
    end;

    procedure ValidatePostingRequirements()
    begin
        _employee.TestField("Privacy Blocked", false);
        _employee.TestField(Status, "Employee Status"::Active);
        if HasConstraints() then
            ValidateConstraints();
    end;

    procedure CanChangeClientName(): Boolean
    begin
        exit(false);
    end;
}
