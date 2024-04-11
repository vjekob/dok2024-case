namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Setup;

table 50007 "DEMO Rental Header"
{
    Caption = 'Rental Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }

        field(2; "Client Type"; Enum "DEMO Rental Client Type")
        {
            Caption = 'Client Type';

            trigger OnValidate()
            var
                RentalLine: Record "DEMO Rental Line";
                IsHandled: Boolean;
                DeleteLinesQst: Label 'Changing %1 will delete all lines. Do you want to continue?', Comment = '%1 is field name.';
            begin
                OnValidateClientType(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if Rec."Client Type" = xRec."Client Type" then
                    exit;

                RentalLine.SetRange("Document No.", Rec."No.");
                if RentalLine.IsEmpty() then
                    exit;

                if not Confirm(DeleteLinesQst, false, Rec.FieldCaption("Client Type")) then
                    exit;

                RentalLine.DeleteAll(false);
            end;
        }

        field(3; "Client No."; Code[20])
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

        field(4; "Client Name"; Text[100])
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

        field(5; "E-Mail"; Text[80])
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

        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(7; "Gen. Bus. Posting Group"; Code[10])
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

        field(8; "Posting Group Mandatory"; Boolean)
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
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }


    [IntegrationEvent(true, false)]
    local procedure OnValidateClientType(var Rec: Record "DEMO Rental Header"; var xRec: Record "DEMO Rental Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateClientName(var Rec: Record "DEMO Rental Header"; var xRec: Record "DEMO Rental Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateEMail(var Rec: Record "DEMO Rental Header"; var xRec: Record "DEMO Rental Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateGenBusPostingGroup(var Rec: Record "DEMO Rental Header"; var xRec: Record "DEMO Rental Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidatePostingGroupMandatory(var Rec: Record "DEMO Rental Header"; var xRec: Record "DEMO Rental Header"; var IsHandled: Boolean)
    begin
    end;
}
