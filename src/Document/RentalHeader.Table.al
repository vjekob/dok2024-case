namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.HumanResources.Setup;
using Microsoft.CRM.BusinessRelation;

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
    local procedure OnValidateClientNo(var Rec: Record "DEMO Rental Header"; var xRec: Record "DEMO Rental Header"; var IsHandled: Boolean)
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
