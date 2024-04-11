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
        ClientType: Interface "DEMO Rental Client Type";
        IsHandled: Boolean;
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

        CheckClientObjectTypeCombination(RentalJnlLine);
        CheckQuantity(RentalJnlLine);

        ClientType := RentalJnlLine."Client Type";
        ClientType.Initialize(RentalJnlLine."Client No.");
        ClientType.ValidatePostingRequirements();

        OnAfterRunCheck(RentalJnlLine);
    end;

    local procedure CheckClientObjectTypeCombination(var RentalJnlLine: Record "DEMO Rental Journal Line")
    var
        ClientType: Interface "DEMO Rental Client Type";
        ObjectType: Interface "DEMO Rental Object Type";
        InvalidClientTypeObjectTypeCombinationErr: Label 'Invalid client type/object type combination: %1 %2 and %3 %4', Comment = '%1 and %3 are field captions, %2 and %4 are field values';
    begin
        ClientType := RentalJnlLine."Client Type";
        ObjectType := RentalJnlLine.Type;

        if ClientType.AcceptsObjectType(RentalJnlLine) and ObjectType.AcceptsClientType(RentalJnlLine) then
            exit;

        Error(InvalidClientTypeObjectTypeCombinationErr, RentalJnlLine.FieldCaption("Client Type"), RentalJnlLine."Client Type",
            RentalJnlLine.FieldCaption(Type), RentalJnlLine.Type);
    end;

    local procedure CheckQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line")
    var
        ClientType: Interface "DEMO Rental Client Type";
        ObjectType: Interface "DEMO Rental Object Type";
        InvalidQtyForClientTypeObjectTypeCombinationErr: Label 'Invalid quantity for client type/object type combination: %1 %2 and %3 %4', Comment = '%1 and %3 are field captions, %2 and %4 are field values';
    begin
        ClientType := RentalJnlLine."Client Type";
        ObjectType := RentalJnlLine.Type;

        if ClientType.AcceptsQuantity(RentalJnlLine) and ObjectType.AcceptsQuantity(RentalJnlLine) then
            exit;

        Error(InvalidQtyForClientTypeObjectTypeCombinationErr, RentalJnlLine.FieldCaption("Client Type"), RentalJnlLine."Client Type",
            RentalJnlLine.FieldCaption(Type), RentalJnlLine.Type);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var RentalJournalLine: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin
    end;

}
