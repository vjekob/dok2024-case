namespace Vjeko.Demos.Rental;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Location;
using Microsoft.FixedAssets.Setup;

table 50009 "DEMO Rental Line"
{
    Caption = 'Rental Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "DEMO Rental Header";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(3; Type; Enum "DEMO Rental Object Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
                ObjectType: Interface "DEMO Rental Object Type";
            begin
                GetRentalHeader();

                ClientType := RentalHeader."Client Type";
                ObjectType := Rec.Type;

                if not (ClientType.AcceptsObjectType(Rec) and (ObjectType.AcceptsClientType(Rec, RentalHeader))) then
                    Rec.FieldError(Type);

                if Rec.Type = xRec.Type then
                    exit;

                Rec."No." := '';
                ClearFields();
            end;
        }

        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const("DEMO Rental Object Type"::Item)) Item else
            if (Type = const("DEMO Rental Object Type"::Resource)) Resource else
            if (Type = const("DEMO Rental Object Type"::FixedAsset)) "Fixed Asset";

            trigger OnValidate()
            var
                Item: Record Item;
                Resource: Record Resource;
                FixedAsset: Record "Fixed Asset";
                RentalSetup: Record "DEMO Rental Setup";
                ObjectType: Interface "DEMO Rental Object Type";
            begin
                if Rec."No." <> xRec."No." then
                    ClearFields();

                if Rec."No." = '' then
                    exit;

                ObjectType.Initialize(Rec."No.");
                ObjectType.ValidateRequirements();
                ObjectType.AssignDefaults(Rec);
            end;
        }

        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(6; Quantity; Integer)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
                ObjectType: Interface "DEMO Rental Object Type";
                MustNotBeNegativeErr: Label 'must not be negative';
            begin
                GetRentalHeader();

                ClientType := RentalHeader."Client Type";
                ObjectType := Rec.Type;

                if not (ClientType.AcceptsQuantity(Rec) and (ObjectType.AcceptsQuantity(Rec, RentalHeader))) then
                    Rec.FieldError(Quantity, MustNotBeNegativeErr);

                UpdateQuantityBase();
            end;
        }

        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = if (Type = const("DEMO Rental Object Type"::Item)) "Item Unit of Measure".Code where("Item No." = field("No.")) else
            if (Type = const("DEMO Rental Object Type"::Resource)) "Resource Unit of Measure".Code where("Resource No." = field("No."));

            trigger OnValidate()
            var
                ObjectType: Interface "DEMO Rental Object Type";
            begin
                if (Rec."Unit of Measure Code" = '') and (Rec."Unit of Measure Code" <> xRec."Unit of Measure Code") then begin
                    Rec."Quantity (Base)" := 0;
                end;

                ObjectType := Rec.Type;
                ObjectType.ChangeUnitOfMeasure(Rec);

                UpdateQuantityBase();
            end;
        }

        field(8; "Quantity per Unit of Measure"; Decimal)
        {
            Caption = 'Quantity per Unit of Measure';
            Editable = false;
        }

        field(9; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            Editable = false;
        }

        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = if (Type = const("DEMO Rental Object Type"::Item)) Location else
            if (Type = const("DEMO Rental Object Type"::FixedAsset)) "FA Location";

            trigger OnValidate()
            var
                ObjectType: Interface "DEMO Rental Object Type";
            begin
                ObjectType := Rec.Type;
                if not ObjectType.AllowsLocationCode(Rec) then
                    Rec.TestField("Location Code", '');
            end;
        }

        field(12; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        RentalHeader: Record "DEMO Rental Header";
        LastHeaderNo: Code[20];

    local procedure GetRentalHeader()
    begin
        if (LastHeaderNo <> '') and (LastHeaderNo = RentalHeader."No.") then
            exit;

        LastHeaderNo := RentalHeader."No.";
        RentalHeader.Get(LastHeaderNo);
    end;

    local procedure ClearFields()
    begin
        Rec.Description := '';
        Rec.Quantity := 0;
        Rec."Gen. Product Posting Group" := '';
        Rec."Unit of Measure Code" := '';
        Rec."Location Code" := '';
        Rec."Quantity per Unit of Measure" := 0;
        Rec."Quantity (Base)" := 0;
    end;

    local procedure UpdateQuantityBase()
    begin
        Rec."Quantity (Base)" := Rec.Quantity * Rec."Quantity per Unit of Measure";
    end;
}
