namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Location;
using Microsoft.FixedAssets.Setup;

table 50010 "DEMO Rental Journal Line"
{
    Caption = 'Rental Journal Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
        }

        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }

        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(4; "Client Type"; Enum "DEMO Rental Client Type")
        {
            Caption = 'Client Type';

            trigger OnValidate()
            var
                RentalLine: Record "DEMO Rental Journal Line";
            begin
                ClearAllFields();
            end;
        }

        field(5; "Client No."; Code[20])
        {
            Caption = 'Client No.';
            TableRelation = if ("Client Type" = const(Customer)) Customer else
            if ("Client Type" = const(Contact)) Contact else
            if ("Client Type" = const(Employee)) Employee;


            trigger OnValidate()
            var
                Customer: Record Customer;
                Contact, ContactCompany : Record Contact;
                Employee: Record Employee;
                ClientType: Interface "DEMO Rental Client Type";
            begin
                if Rec."Client No." = '' then
                    exit;

                Rec."Posting Group Mandatory" := false;

                ClientType := Rec."Client Type";
                ClientType.Initialize(Rec."Client No.");
                ClientType.ValidateRequirements();
                if ClientType.HasConstraints() then
                    ClientType.ValidateConstraints();
                ClientType.AssignDefaults(Rec);
            end;
        }

        field(6; "Client Name"; Text[100])
        {
            Caption = 'Client Name';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
            begin
                ClientType := Rec."Client Type";
                if not ClientType.CanChangeClientName(Rec) then
                    Rec.FieldError("Client Type");
            end;
        }

        field(7; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
            begin
                ClientType := Rec."Client Type";
                if not ClientType.CanChangeEMail(Rec) then
                    Rec.FieldError("Client Type");
            end;
        }

        field(8; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(9; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
                CannotChangePostingGroupErr: Label 'Posting Group cannot be changed for %1 %2.', Comment = '%1 is client type, %2 is client no.';
            begin
                ClientType := Rec."Client Type";
                if not ClientType.CanChangeGenBusPostingGroup(Rec) then
                    Rec.FieldError("Gen. Bus. Posting Group");
            end;
        }

        field(10; "Posting Group Mandatory"; Boolean)
        {
            Caption = 'Posting Group Mandatory';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
            begin
                ClientType := Rec."Client Type";
                if not ClientType.AllowChangePostingGroupMandatory() then
                    Rec.FieldError("Posting Group Mandatory");
            end;
        }

        field(11; Type; Enum "DEMO Rental Object Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
                ObjectType: Interface "DEMO Rental Object Type";
            begin
                ClientType := Rec."Client Type";
                ObjectType := Rec.Type;

                if not (ClientType.AcceptsObjectType(Rec) and ObjectType.AcceptsClientType(Rec)) then
                    Rec.FieldError(Type);

                if Rec.Type = xRec.Type then
                    exit;

                Rec."No." := '';
                ClearObjectFields();
            end;
        }

        field(12; "No."; Code[20])
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
                    ClearObjectFields();

                if Rec."No." = '' then
                    exit;

                ObjectType := Rec.Type;
                ObjectType.Initialize(Rec."No.");
                ObjectType.ValidateRequirements();
                ObjectType.AssignDefaults(Rec);
            end;
        }

        field(13; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(14; Quantity; Integer)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            var
                ClientType: Interface "DEMO Rental Client Type";
                ObjectType: Interface "DEMO Rental Object Type";
                MustNotBeNegativeErr: Label 'must not be negative';
            begin
                ClientType := Rec."Client Type";
                ObjectType := Rec.Type;

                if not (ClientType.AcceptsQuantity(Rec) and (ObjectType.AcceptsQuantity(Rec))) then
                    Rec.FieldError(Quantity, MustNotBeNegativeErr);

                UpdateQuantityBase();
            end;
        }

        field(15; "Unit of Measure Code"; Code[10])
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

            trigger OnValidate()
            var
                ObjectType: Interface "DEMO Rental Object Type";
            begin
                ObjectType := Rec.Type;
                if not ObjectType.AllowsLocationCode(Rec) then
                    Rec.TestField("Location Code", '');
            end;
        }

        field(19; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
    }

    keys
    {
        key(PK; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure EmptyLine(): Boolean
    begin
        exit((Rec."Client No." = '') and (Rec.Quantity = 0) and (Rec."No." = ''));
    end;

    local procedure ClearAllFields()
    begin
        Rec."Client No." := '';
        Rec."Client Name" := '';
        Rec."Posting Date" := 0D;
        Rec."Gen. Bus. Posting Group" := '';
        Rec."Posting Group Mandatory" := false;
        ClearObjectFields();
    end;

    local procedure ClearObjectFields()
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
