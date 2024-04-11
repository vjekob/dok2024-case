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
                IsHandled: Boolean;
            begin
                OnValidateType(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                GetRentalHeader();

                if (((RentalHeader."Client Type" = "DEMO Rental Client Type"::Contact) or (RentalHeader."Client Type" = "DEMO Rental Client Type"::Customer)) and
                    (Type = "DEMO Rental Object Type"::FixedAsset)) or
                    ((RentalHeader."Client Type" = "DEMO Rental Client Type"::Employee) and
                    (not (Type in ["DEMO Rental Object Type"::FixedAsset, "DEMO Rental Object Type"::Resource])))
                then
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
                IsHandled: Boolean;
            begin
                OnValidateNo(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if Rec."No." <> xRec."No." then
                    ClearFields();

                if Rec."No." = '' then
                    exit;

                case Type of
                    "DEMO Rental Object Type"::Item:
                        begin
                            Item.Get(Rec."No.");
                            Item.TestField("Gen. Prod. Posting Group");
                            Item.TestField("Inventory Posting Group");
                            Item.TestField("DEMO Rental Unit of Measure");
                            Item.TestField(Blocked, false);

                            Rec.Description := Item.Description;
                            Rec."Gen. Product Posting Group" := Item."Gen. Prod. Posting Group";
                            Rec."Unit of Measure Code" := Item."DEMO Rental Unit of Measure";
                        end;

                    "DEMO Rental Object Type"::Resource:
                        begin
                            Resource.Get(Rec."No.");
                            Resource.TestField("Gen. Prod. Posting Group");
                            Resource.TestField("Base Unit of Measure");
                            Resource.TestField(Blocked, false);

                            Rec.Description := Resource.Name;
                            Rec."Gen. Product Posting Group" := Resource."Gen. Prod. Posting Group";
                            Rec."Unit of Measure Code" := Resource."Base Unit of Measure";
                        end;

                    "DEMO Rental Object Type"::FixedAsset:
                        begin
                            FixedAsset.Get(Rec."No.");
                            FixedAsset.TestField(Blocked, false);
                            FixedAsset.TestField(Inactive, false);
                            FixedAsset.TestField(Acquired, true);
                            FixedAsset.TestField(Insured, true);
                            FixedAsset.TestField("Under Maintenance", false);
                            FixedAsset.TestField("Component of Main Asset", '');
                            if not (FixedAsset."Main Asset/Component" in ["FA Component Type"::" ", "FA Component Type"::"Main Asset"]) then
                                FixedAsset.FieldError("Main Asset/Component");

                            RentalSetup.Get();
                            RentalSetup.TestField("FA Gen. Prod. Posting Group");

                            Rec.Description := FixedAsset.Description;
                            Rec."Gen. Product Posting Group" := RentalSetup."FA Gen. Prod. Posting Group";
                            Rec."Location Code" := FixedAsset."FA Location Code";
                            Rec.Quantity := 1;
                            Rec."Quantity per Unit of Measure" := 1;
                            Rec."Quantity (Base)" := 1;
                        end;
                end;
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
                IsHandled: Boolean;
                MustNotBeNegativeErr: Label 'must not be negative';
            begin
                OnValidateQuantity(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                GetRentalHeader();

                if (
                    ((Type = "DEMO Rental Object Type"::Resource) and (RentalHeader."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Customer]))
                    or ((Type = "DEMO Rental Object Type"::Item) and (RentalHeader."Client Type" = "DEMO Rental Client Type"::Customer))
                    or (Type = "DEMO Rental Object Type"::FixedAsset)
                ) and (Rec.Quantity < 0) then
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
                ItemUoM: Record "Item Unit of Measure";
                ResourceUoM: Record "Resource Unit of Measure";
                IsHandled: Boolean;
                CannotChangeUoMErr: Label 'You cannot change the unit of measure when %1 is %2.', Comment = '%1 is Type caption, %2 is Type value.';
            begin
                OnValidateUnitOfMeasureCode(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if (Rec."Unit of Measure Code" = '') and (Rec."Unit of Measure Code" <> xRec."Unit of Measure Code") then begin
                    Rec."Quantity (Base)" := 0;
                end;

                case Rec.Type of
                    "DEMO Rental Object Type"::Item:
                        begin
                            ItemUoM.Get(Rec."No.", Rec."Unit of Measure Code");
                            Rec."Quantity per Unit of Measure" := ItemUoM."Qty. per Unit of Measure";
                        end;
                    "DEMO Rental Object Type"::Resource:
                        begin
                            ResourceUoM.Get(Rec."No.", Rec."Unit of Measure Code");
                            Rec."Quantity per Unit of Measure" := ResourceUoM."Qty. per Unit of Measure";
                        end;
                    else
                        Error(CannotChangeUoMErr, Rec.FieldCaption(Type), Rec.Type);
                end;

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
                IsHandled: Boolean;
            begin
                OnValidateLocationCode(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if (Type = "DEMO Rental Object Type"::Resource) then
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

    [IntegrationEvent(false, false)]
    local procedure OnValidateType(var Rec: Record "DEMO Rental Line"; var xRec: Record "DEMO Rental Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNo(var Rec: Record "DEMO Rental Line"; var xRec: Record "DEMO Rental Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantity(var Rec: Record "DEMO Rental Line"; var xRec: Record "DEMO Rental Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateUnitOfMeasureCode(var Rec: Record "DEMO Rental Line"; var xRec: Record "DEMO Rental Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLocationCode(var Rec: Record "DEMO Rental Line"; var xRec: Record "DEMO Rental Line"; var IsHandled: Boolean);
    begin
    end;
}
