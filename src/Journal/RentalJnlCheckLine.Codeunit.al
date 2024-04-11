namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;
using Microsoft.CRM.Contact;
using Microsoft.HumanResources.Employee;
using Microsoft.CRM.BusinessRelation;
using Microsoft.HumanResources.Setup;

codeunit 50027 "DEMO Rental Jnl.-Check Line"
{
    TableNo = "DEMO Rental Journal Line";

    trigger OnRun()
    begin
        RentalSetup.Get();
        RunCheck(Rec);
    end;

    var
        RentalSetup: Record "DEMO Rental Setup";

    procedure RunCheck(var RentalJnlLine: Record "DEMO Rental Journal Line")
    var
        Customer: Record Customer;
        Contact, ContactCompany : Record Contact;
        Employee: Record Employee;
        ContactBusinessRelation: Record "Contact Business Relation";
        Union: Record Union;
        IsHandled: Boolean;
        InvalidClientTypeObjectTypeCombinationErr: Label 'Invalid client type/object type combination: %1 %2 and %3 %4', Comment = '%1 and %3 are field captions, %2 and %4 are field values';
        InvalidQtyForClientTypeObjectTypeCombinationErr: Label 'Invalid quantity for client type/object type combination: %1 %2 and %3 %4', Comment = '%1 and %3 are field captions, %2 and %4 are field values';
        MaximumBalanceExceededErr: Label 'Unable to proceed with rental for customer %1: outstanding balance exceeds the maximum allowed limit.', Comment = '%1 is customer no.';
        RelatedCustomerBlockedErr: Label 'Unable to proceed with rental for contact %1: related customer %2 is blocked.', Comment = '%1 is contact no., %2 is customer no.';
        RelatedCustomerExceedsBalanceErr: Label 'Unable to proceed with rental for contact %1: related customer %2 exceeds the maximum allowed balance.', Comment = '%1 is contact no., %2 is customer no.';
        UnionDoesNotAllowRentalErr: Label 'Unable to proceed with rental for employee %1: the employee belongs to union %2 that does not allow rentals.', Comment = '%1 is employee no., %2 is union code.';
    begin
        IsHandled := false;
        OnBeforeRunCheck(RentalJnlLine, IsHandled);
        if IsHandled then
            exit;

        if RentalJnlLine.EmptyLine() then
            exit;

        RentalJnlLine.TestField("Client No.");
        RentalJnlLine.TestField("No.");
        RentalJnlLine.TestField("Posting Date");
        RentalJnlLine.TestField(Quantity);
        RentalJnlLine.TestField("Unit of Measure Code");
        RentalJnlLine.TestField("E-Mail");
        RentalJnlLine.TestField("Gen. Bus. Posting Group");
        RentalJnlLine.TestField("Gen. Product Posting Group");

        IsHandled := false;
        OnBeforeCheckClientObjectTypeCombination(RentalJnlLine, IsHandled);
        if not IsHandled then
            if (((RentalJnlLine."Client Type" = "DEMO Rental Client Type"::Contact) or (RentalJnlLine."Client Type" = "DEMO Rental Client Type"::Customer)) and
                (RentalJnlLine.Type = "DEMO Rental Object Type"::FixedAsset)) or
                ((RentalJnlLine."Client Type" = "DEMO Rental Client Type"::Employee) and
                (not (RentalJnlLine.Type in ["DEMO Rental Object Type"::FixedAsset, "DEMO Rental Object Type"::Resource])))
            then
                Error(InvalidClientTypeObjectTypeCombinationErr, RentalJnlLine.FieldCaption("Client Type"), RentalJnlLine."Client Type",
                    RentalJnlLine.FieldCaption(Type), RentalJnlLine.Type);

        IsHandled := false;
        OnBeforeCheckQuantity(RentalJnlLine, IsHandled);
        if not IsHandled then
            if (
                ((RentalJnlLine.Type = "DEMO Rental Object Type"::Resource) and (RentalJnlLine."Client Type" in ["DEMO Rental Client Type"::Contact, "DEMO Rental Client Type"::Customer]))
                or ((RentalJnlLine.Type = "DEMO Rental Object Type"::Item) and (RentalJnlLine."Client Type" = "DEMO Rental Client Type"::Customer))
                or (RentalJnlLine.Type = "DEMO Rental Object Type"::FixedAsset)
            ) and (RentalJnlLine.Quantity < 0) then
                Error(InvalidQtyForClientTypeObjectTypeCombinationErr, RentalJnlLine.FieldCaption("Client Type"), RentalJnlLine."Client Type",
                    RentalJnlLine.FieldCaption(Type), RentalJnlLine.Type);

        IsHandled := false;
        OnBeforeCheckClient(RentalJnlLine, IsHandled);
        if not IsHandled then
            case RentalJnlLine."Client Type" of
                "DEMO Rental Client Type"::Customer:
                    begin
                        Customer.Get(RentalJnlLine."Client No.");
                        Customer.TestField(Blocked, "Customer Blocked"::" ");
                        Customer.CalcFields("Balance Due (LCY)");
                        if Customer."Balance Due (LCY)" > RentalSetup."Maximum Balance (LCY)" then
                            Error(MaximumBalanceExceededErr, RentalJnlLine."Client No.");
                    end;

                "DEMO Rental Client Type"::Contact:
                    begin
                        Contact.Get(RentalJnlLine."Client No.");
                        Contact.TestField(Type, "Contact Type"::"Person");
                        Contact.TestField("Privacy Blocked", false);
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
                                                Error(RelatedCustomerBlockedErr, RentalJnlLine."Client No.", Customer."No.");
                                            if Customer."Balance Due (LCY)" > RentalSetup."Maximum Balance (LCY)" then
                                                Error(RelatedCustomerExceedsBalanceErr, RentalJnlLine."Client No.", Customer."No.");
                                        end;
                                    until ContactBusinessRelation.Next() = 0;
                            end;
                        end;
                    end;

                "DEMO Rental Client Type"::Employee:
                    begin
                        Employee.Get(RentalJnlLine."Client No.");
                        Employee.TestField("Privacy Blocked", false);
                        Employee.TestField(Status, "Employee Status"::Active);

                        if Employee."Union Code" <> '' then begin
                            Employee.TestField("Union Membership No.");
                            Union.Get(Employee."Union Code");
                            if Union."DEMO Rental Allowed" = false then
                                Error(UnionDoesNotAllowRentalErr, RentalJnlLine."Client No.", Union."Code");
                        end;
                    end;
            end;

        OnAfterRunCheck(RentalJnlLine);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var RentalJournalLine: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckClientObjectTypeCombination(var RentalJournalLine: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckQuantity(var RentalJournalLine: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckClient(var RentalJournalLine: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin
    end;

}
