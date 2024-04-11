namespace Vjeko.Demos.Rental;

using Microsoft.FixedAssets.FixedAsset;

codeunit 50030 "DEMO Rental Object - FA" implements "DEMO Rental Object Type"
{
    var
        _fixedAsset: Record "Fixed Asset";

    procedure Initialize(No: Code[20])
    begin
        _fixedAsset.Get(No);
    end;

    procedure ValidateRequirements()
    begin
        _fixedAsset.TestField(Blocked, false);
        _fixedAsset.TestField(Inactive, false);
        _fixedAsset.TestField(Acquired, true);
        _fixedAsset.TestField(Insured, true);
        _fixedAsset.TestField("Under Maintenance", false);
        _fixedAsset.TestField("Component of Main Asset", '');
        if not (_fixedAsset."Main Asset/Component" in ["FA Component Type"::" ", "FA Component Type"::"Main Asset"]) then
            _fixedAsset.FieldError("Main Asset/Component");
    end;

    procedure AssignDefaults(var RentalLine: Record "DEMO Rental Line")
    var
        RentalSetup: Record "DEMO Rental Setup";
    begin
        RentalSetup.Get();
        RentalSetup.TestField("FA Gen. Prod. Posting Group");

        RentalLine.Description := _fixedAsset.Description;
        RentalLine."Gen. Product Posting Group" := RentalSetup."FA Gen. Prod. Posting Group";
        RentalLine."Location Code" := _fixedAsset."FA Location Code";
        RentalLine.Quantity := 1;
        RentalLine."Quantity per Unit of Measure" := 1;
        RentalLine."Quantity (Base)" := 1;
    end;

    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line")
    var
        RentalSetup: Record "DEMO Rental Setup";
    begin
        RentalSetup.Get();
        RentalSetup.TestField("FA Gen. Prod. Posting Group");

        RentalJournalLine.Description := _fixedAsset.Description;
        RentalJournalLine."Gen. Product Posting Group" := RentalSetup."FA Gen. Prod. Posting Group";
        RentalJournalLine."Location Code" := _fixedAsset."FA Location Code";
        RentalJournalLine.Quantity := 1;
        RentalJournalLine."Quantity per Unit of Measure" := 1;
        RentalJournalLine."Quantity (Base)" := 1;
    end;

    procedure ChangeUnitOfMeasure(var RentalLine: Record "DEMO Rental Line")
    begin
        FailChangeUnitOfMeasure(RentalLine.FieldCaption(Type));
    end;

    procedure ChangeUnitOfMeasure(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin
        FailChangeUnitOfMeasure(RentalJournalLine.FieldCaption(Type));
    end;

    local procedure FailChangeUnitOfMeasure(Field: Text)
    var
        CannotChangeUoMErr: Label 'You cannot change the unit of measure when %1 is %2.', Comment = '%1 is Type caption, %2 is Type value.';
    begin
        Error(CannotChangeUoMErr, Field, "DEMO Rental Object Type"::FixedAsset);
    end;

    procedure AcceptsClientType(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        if RentalHeader."Client Type" in ["DEMO Rental Client Type"::Customer, "DEMO Rental Client Type"::Contact] then
            exit(false);

        exit(true);
    end;

    procedure AcceptsClientType(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJournalLine."Client Type" in ["DEMO Rental Client Type"::Customer, "DEMO Rental Client Type"::Contact] then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        if RentalLine.Quantity >= 0 then
            exit(true);

        if RentalHeader."Client Type" in ["DEMO Rental Client Type"::Customer, "DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Employee] then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJnlLine.Quantity >= 0 then
            exit(true);

        if RentalJnlLine."Client Type" in ["DEMO Rental Client Type"::Customer, "DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Employee] then
            exit(false);

        exit(true);
    end;

    procedure AllowsLocationCode(var RentalLine: Record "DEMO Rental Line"): Boolean
    begin
        exit(true);
    end;

    procedure AllowsLocationCode(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        exit(true);
    end;
}
