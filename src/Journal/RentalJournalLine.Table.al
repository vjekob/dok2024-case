namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.HumanResources.Setup;
using Microsoft.CRM.BusinessRelation;
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
                IsHandled: Boolean;
                DeleteLinesQst: Label 'Changing %1 will delete all lines. Do you want to continue?', Comment = '%1 is field name.';
            begin
                OnValidateClientType(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

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
                RentalSetup: Record "DEMO Rental Setup";
                ContactBusinessRelation: Record "Contact Business Relation";
                Union: Record Union;
                IsHandled: Boolean;
                MaximumBalanceExceededErr: Label 'Unable to proceed with rental for customer %1: outstanding balance exceeds the maximum allowed limit.', Comment = '%1 is customer no.';
                RelatedCustomerBlockedErr: Label 'Unable to proceed with rental for contact %1: related customer %2 is blocked.', Comment = '%1 is contact no., %2 is customer no.';
                RelatedCustomerExceedsBalanceErr: Label 'Unable to proceed with rental for contact %1: related customer %2 exceeds the maximum allowed balance.', Comment = '%1 is contact no., %2 is customer no.';
                UnionDoesNotAllowRentalErr: Label 'Unable to proceed with rental for employee %1: the employee belongs to union %2 that does not allow rentals.', Comment = '%1 is employee no., %2 is union code.';
            begin
                OnValidateClientNo(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if Rec."Client No." = '' then
                    exit;

                Rec."Posting Group Mandatory" := false;

                case Rec."Client Type" of
                    "DEMO Rental Client Type"::Customer:
                        begin
                            Customer.Get(Rec."Client No.");
                            Customer.TestField(Blocked, "Customer Blocked"::" ");
                            Customer.TestField("E-Mail");
                            Customer.TestField("Customer Posting Group");
                            Customer.TestField("Gen. Bus. Posting Group");
                            Customer.TestField("VAT Bus. Posting Group");
                            Customer.TestField("Payment Terms Code");

                            RentalSetup.Get();
                            RentalSetup.TestField("Maximum Balance (LCY)");
                            Customer.CalcFields("Balance Due (LCY)");
                            if Customer."Balance Due (LCY)" > RentalSetup."Maximum Balance (LCY)" then
                                Error(MaximumBalanceExceededErr, Rec."Client No.");

                            Rec."Client Name" := Customer.Name;
                            Rec."E-Mail" := Customer."E-Mail";
                            Rec."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
                        end;
                    "DEMO Rental Client Type"::Contact:
                        begin
                            Contact.Get(Rec."Client No.");
                            Contact.TestField(Type, "Contact Type"::Person);
                            Contact.TestField("Privacy Blocked", false);
                            Contact.TestField(Name);
                            Contact.TestField("E-Mail");
                            Contact.TestField(Address);
                            Contact.TestField("Post Code");
                            Contact.TestField(City);
                            if Contact.Minor then
                                Contact.TestField("Parental Consent Received");

                            if Contact."Company No." <> '' then begin
                                ContactCompany.Get(Contact."Company No.");
                                if ContactCompany."Contact Business Relation" = "Contact Business Relation"::Customer then begin
                                    ContactBusinessRelation.SetRange("Contact No.", ContactCompany."No.");
                                    ContactBusinessRelation.SetRange("Link to Table", "Contact Business Relation Link To Table"::Customer);
                                    ContactBusinessRelation.SetFilter("No.", '<>%1', '');
                                    if ContactBusinessRelation.FindSet() then
                                        repeat
                                            Customer.SetAutoCalcFields("Balance Due (LCY)");
                                            if Customer.Get(ContactBusinessRelation."No.") then begin
                                                if Customer.Blocked <> "Customer Blocked"::" " then
                                                    Error(RelatedCustomerBlockedErr, Rec."Client No.", Customer."No.");
                                                if Customer."Balance Due (LCY)" > RentalSetup."Maximum Balance (LCY)" then
                                                    Error(RelatedCustomerExceedsBalanceErr, Rec."Client No.", Customer."No.");
                                            end;
                                        until ContactBusinessRelation.Next() = 0;
                                end;
                            end;

                            Rec."Client Name" := Contact.Name;
                            Rec."E-Mail" := Contact."E-Mail";
                            Rec."Gen. Bus. Posting Group" := Contact."DEMO Gen. Bus. Posting Group";
                            Rec."Posting Group Mandatory" := Contact."DEMO Posting Group Mandatory";
                        end;
                    "DEMO Rental Client Type"::Employee:
                        begin
                            Employee.Get(Rec."Client No.");
                            Employee.TestField("Privacy Blocked", false);
                            Employee.TestField(Status, "Employee Status"::Active);
                            Employee.TestField("E-Mail");

                            if Employee."Union Code" <> '' then begin
                                Employee.TestField("Union Membership No.");
                                Union.Get(Employee."Union Code");
                                if Union."DEMO Rental Allowed" = false then
                                    Error(UnionDoesNotAllowRentalErr, Rec."Client No.", Union."Code");
                            end;

                            Rec."Client Name" := Employee.FullName();
                            Rec."E-Mail" := Employee."E-Mail";
                            RentalSetup.Get();
                            Rec."Gen. Bus. Posting Group" := RentalSetup."Employee Gen.Bus.Posting Group";
                        end;
                end;
            end;
        }

        field(6; "Client Name"; Text[100])
        {
            Caption = 'Client Name';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                OnValidateClientName(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if Rec."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Employee] then
                    Rec.FieldError("Client Type");
            end;
        }

        field(7; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                OnValidateEMail(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if Rec."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Employee] then
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
                IsHandled: Boolean;
                CannotChangePostingGroupErr: Label 'Posting Group cannot be changed for %1 %2.', Comment = '%1 is client type, %2 is client no.';
            begin
                OnValidateGenBusPostingGroup(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if (Rec."Client Type" = "DEMO Rental Client Type"::Employee) or
                    ((Rec."Client Type" = "DEMO Rental Client Type"::Contact) and (Rec."Posting Group Mandatory"))
                then
                    Error(CannotChangePostingGroupErr, Rec."Client Type", Rec."Client No.");
            end;
        }

        field(10; "Posting Group Mandatory"; Boolean)
        {
            Caption = 'Posting Group Mandatory';

            trigger OnValidate()
            var
                IsHandled: Boolean;
                ConfirmChangeQst: Label 'Changing %1 is not recommended as it may affect posting. Do you want to continue?', Comment = '%1 is field name.';
            begin
                OnValidatePostingGroupMandatory(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                case Rec."Client Type" of
                    "DEMO Rental Client Type"::Customer, "DEMO Rental Client Type"::Employee:
                        Rec.FieldError("Client Type");
                    "DEMO Rental Client Type"::Contact:
                        if not Confirm(ConfirmChangeQst, false, Rec."Posting Group Mandatory") then
                            Error('');
                end;
            end;
        }

        field(11; Type; Enum "DEMO Rental Object Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                OnValidateType(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if (((Rec."Client Type" = "DEMO Rental Client Type"::Contact) or (Rec."Client Type" = "DEMO Rental Client Type"::Customer)) and
                    (Type = "DEMO Rental Object Type"::FixedAsset)) or
                    ((Rec."Client Type" = "DEMO Rental Client Type"::Employee) and
                    (not (Type in ["DEMO Rental Object Type"::FixedAsset, "DEMO Rental Object Type"::Resource])))
                then
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
                IsHandled: Boolean;
            begin
                OnValidateNo(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if Rec."No." <> xRec."No." then
                    ClearObjectFields();

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

        field(13; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(14; Quantity; Integer)
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

                if (
                    ((Type = "DEMO Rental Object Type"::Resource) and (Rec."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Customer]))
                    or ((Type = "DEMO Rental Object Type"::Item) and (Rec."Client Type" = "DEMO Rental Client Type"::Customer))
                    or (Type = "DEMO Rental Object Type"::FixedAsset)
                ) and (Rec.Quantity < 0) then
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
                IsHandled: Boolean;
            begin
                OnValidateLocationCode(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if (Type = "DEMO Rental Object Type"::Resource) then
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

    [IntegrationEvent(true, false)]
    local procedure OnValidateClientType(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateClientNo(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateClientName(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateEMail(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateGenBusPostingGroup(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidatePostingGroupMandatory(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateType(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateNo(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateQuantity(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateUnitOfMeasureCode(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLocationCode(var Rec: Record "DEMO Rental Journal Line"; var xRec: Record "DEMO Rental Journal Line"; var IsHandled: Boolean);
    begin
    end;
}
