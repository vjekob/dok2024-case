namespace Vjeko.Demos.Rental;

using Microsoft.Projects.Resources.Resource;

codeunit 50029 "DEMO Rental Object - Resource" implements "DEMO Rental Object Type"
{
    var
        _resource: Record Resource;

    procedure Initialize(No: Code[20])
    begin
        _resource.Get(No);
    end;

    procedure ValidateRequirements()
    begin
        _resource.TestField("Gen. Prod. Posting Group");
        _resource.TestField("Base Unit of Measure");
        _resource.TestField(Blocked, false);
    end;

    procedure AssignDefaults(var RentalLine: Record "DEMO Rental Line")
    begin
        RentalLine.Description := _resource.Name;
        RentalLine."Gen. Product Posting Group" := _resource."Gen. Prod. Posting Group";
        RentalLine."Unit of Measure Code" := _resource."Base Unit of Measure";
    end;

    procedure AssignDefaults(var RentalJournal: Record "DEMO Rental Journal Line")
    begin
        RentalJournal.Description := _resource.Name;
        RentalJournal."Gen. Product Posting Group" := _resource."Gen. Prod. Posting Group";
        RentalJournal."Unit of Measure Code" := _resource."Base Unit of Measure";
    end;

    procedure ChangeUnitOfMeasure(var RentalLine: Record "DEMO Rental Line")
    var
        ResourceUoM: Record "Resource Unit of Measure";
    begin
        ResourceUoM.Get(RentalLine."No.", RentalLine."Unit of Measure Code");
        RentalLine."Quantity per Unit of Measure" := ResourceUoM."Qty. per Unit of Measure";
    end;

    procedure ChangeUnitOfMeasure(var RentalJournalLine: Record "DEMO Rental Journal Line")
    var
        ResourceUoM: Record "Resource Unit of Measure";
    begin
        ResourceUoM.Get(RentalJournalLine."No.", RentalJournalLine."Unit of Measure Code");
        RentalJournalLine."Quantity per Unit of Measure" := ResourceUoM."Qty. per Unit of Measure";
    end;

    procedure AcceptsClientType(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        exit(true);
    end;

    procedure AcceptsClientType(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        exit(true);
    end;

    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        if RentalLine.Quantity >= 0 then
            exit(true);

        if RentalHeader."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Customer] then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJnlLine.Quantity >= 0 then
            exit(true);

        if RentalJnlLine."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Customer] then
            exit(false);

        exit(true);
    end;

    procedure AllowsLocationCode(var RentalLine: Record "DEMO Rental Line"): Boolean
    begin
        exit(false);
    end;

    procedure AllowsLocationCode(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        exit(false);
    end;
}