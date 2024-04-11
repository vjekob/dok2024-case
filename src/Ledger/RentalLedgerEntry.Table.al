namespace Vjeko.Demos.Rental;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Location;
using Microsoft.FixedAssets.Setup;
using Microsoft.Utilities;

table 50012 "DEMO Rental Ledger Entry"
{
    Caption = 'Rental Ledger Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }

        field(2; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
        }

        field(3; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }

        field(4; "Client Type"; Enum "DEMO Rental Client Type")
        {
            Caption = 'Client Type';
        }

        field(5; "Client No."; Code[20])
        {
            Caption = 'Client No.';
            TableRelation = if ("Client Type" = const(Customer)) Customer else
            if ("Client Type" = const(Contact)) Contact else
            if ("Client Type" = const(Employee)) Employee;
        }

        field(6; "Client Name"; Text[100])
        {
            Caption = 'Client Name';
        }

        field(7; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
        }

        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(9; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }

        field(10; "Posting Group Mandatory"; Boolean)
        {
            Caption = 'Posting Group Mandatory';
        }

        field(11; Type; Enum "DEMO Rental Object Type")
        {
            Caption = 'Type';
        }

        field(12; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const("DEMO Rental Object Type"::Item)) Item else
            if (Type = const("DEMO Rental Object Type"::Resource)) Resource else
            if (Type = const("DEMO Rental Object Type"::FixedAsset)) "Fixed Asset";
        }

        field(13; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(14; Quantity; Integer)
        {
            Caption = 'Quantity';
        }

        field(15; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = if (Type = const("DEMO Rental Object Type"::Item)) "Item Unit of Measure".Code where("Item No." = field("No.")) else
            if (Type = const("DEMO Rental Object Type"::Resource)) "Resource Unit of Measure".Code where("Resource No." = field("No."));
        }

        field(16; "Quantity per Unit of Measure"; Decimal)
        {
            Caption = 'Quantity per Unit of Measure';
            Editable = false;
        }

        field(17; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            Editable = false;
        }

        field(18; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = if (Type = const("DEMO Rental Object Type"::Item)) Location else
            if (Type = const("DEMO Rental Object Type"::FixedAsset)) "FA Location";
        }

        field(19; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure CopyFromRentalJnlLine(RentalJnlLine: Record "DEMO Rental Journal Line")
    begin
        Rec."Journal Template Name" := RentalJnlLine."Journal Template Name";
        Rec."Journal Batch Name" := RentalJnlLine."Journal Batch Name";
        Rec."Client Type" := RentalJnlLine."Client Type";
        Rec."Client No." := RentalJnlLine."Client No.";
        Rec."Client Name" := RentalJnlLine."Client Name";
        Rec."E-Mail" := RentalJnlLine."E-Mail";
        Rec."Posting Date" := RentalJnlLine."Posting Date";
        Rec."Gen. Bus. Posting Group" := RentalJnlLine."Gen. Bus. Posting Group";
        Rec."Posting Group Mandatory" := RentalJnlLine."Posting Group Mandatory";
        Rec.Type := RentalJnlLine.Type;
        Rec."No." := RentalJnlLine."No.";
        Rec.Description := RentalJnlLine.Description;
        Rec.Quantity := RentalJnlLine.Quantity;
        Rec."Unit of Measure Code" := RentalJnlLine."Unit of Measure Code";
        Rec."Quantity per Unit of Measure" := RentalJnlLine."Quantity per Unit of Measure";
        Rec."Quantity (Base)" := RentalJnlLine."Quantity (Base)";
        Rec."Location Code" := RentalJnlLine."Location Code";
        Rec."Gen. Product Posting Group" := RentalJnlLine."Gen. Product Posting Group";
    end;

}
