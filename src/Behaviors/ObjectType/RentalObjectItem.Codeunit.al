namespace Vjeko.Demos.Rental;

using Microsoft.Inventory.Item;

codeunit 50028 "DEMO Rental Object - Item" implements "DEMO Rental Object Type"
{
    var
        _item: Record Item;

    procedure Initialize(No: Code[20])
    begin
        _item.Get(No);
    end;

    procedure ValidateRequirements()
    begin
        _item.TestField("Gen. Prod. Posting Group");
        _item.TestField("Inventory Posting Group");
        _item.TestField("DEMO Rental Unit of Measure");
        _item.TestField(Blocked, false);
    end;

    procedure AssignDefaults(var RentalLine: Record "DEMO Rental Line")
    begin
        RentalLine.Description := _item.Description;
        RentalLine."Gen. Product Posting Group" := _item."Gen. Prod. Posting Group";
        RentalLine."Unit of Measure Code" := _item."DEMO Rental Unit of Measure";
    end;

    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin
        RentalJournalLine.Description := _item.Description;
        RentalJournalLine."Gen. Product Posting Group" := _item."Gen. Prod. Posting Group";
        RentalJournalLine."Unit of Measure Code" := _item."DEMO Rental Unit of Measure";
    end;

    procedure ChangeUnitOfMeasure(var RentalLine: Record "DEMO Rental Line")
    var
        ItemUoM: Record "Item Unit of Measure";
    begin
        ItemUoM.Get(RentalLine."No.", RentalLine."Unit of Measure Code");
        RentalLine."Quantity per Unit of Measure" := ItemUoM."Qty. per Unit of Measure";
    end;

    procedure ChangeUnitOfMeasure(var RentalJournalLine: Record "DEMO Rental Journal Line")
    var
        ItemUoM: Record "Item Unit of Measure";
    begin
        ItemUoM.Get(RentalJournalLine."No.", RentalJournalLine."Unit of Measure Code");
        RentalJournalLine."Quantity per Unit of Measure" := ItemUoM."Qty. per Unit of Measure";
    end;

    procedure AcceptsClientType(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        if RentalHeader."Client Type" = "DEMO Rental Client Type"::Employee then
            exit(false);

        exit(true);
    end;

    procedure AcceptsClientType(var RentalJournalLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJournalLine."Client Type" = "DEMO Rental Client Type"::Employee then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"; RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        if RentalLine.Quantity >= 0 then
            exit(true);

        if RentalHeader."Client Type" = "DEMO Rental Client Type"::Customer then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJnlLine.Quantity >= 0 then
            exit(true);

        if RentalJnlLine."Client Type" = "DEMO Rental Client Type"::Customer then
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
