namespace Vjeko.Demos.Rental;

using Microsoft.CRM.Contact;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Sales.Customer;

codeunit 50033 "DEMO Rental Client - Contact" implements "DEMO Rental Client Type"
{
    var
        _contact: Record Contact;

    procedure Initialize(No: Code[20])
    begin
        _contact.Get(No);
    end;

    procedure ValidateRequirements()
    begin
        _contact.TestField(Type, "Contact Type"::Person);
        _contact.TestField("Privacy Blocked", false);
        _contact.TestField(Name);
        _contact.TestField("E-Mail");
        _contact.TestField(Address);
        _contact.TestField("Post Code");
        _contact.TestField(City);
        if _contact.Minor then
            _contact.TestField("Parental Consent Received");
    end;

    procedure HasConstraints(): Boolean
    begin
        exit(_contact."Company No." <> '');
    end;

    procedure ValidateConstraints(): Boolean
    var
        ContactCompany: Record Contact;
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        ClientTypeCustomer: Codeunit "DEMO Rental Client - Customer";
        RelatedCustomerBlockedErr: Label 'Unable to proceed with rental for contact %1: related customer %2 is blocked.', Comment = '%1 is contact no., %2 is customer no.';
    begin
        ContactCompany.Get(_contact."Company No.");
        if ContactCompany."Contact Business Relation" = "Contact Business Relation"::Customer then begin
            ContactBusinessRelation.SetRange("Contact No.", ContactCompany."No.");
            ContactBusinessRelation.SetRange("Link to Table", "Contact Business Relation Link To Table"::Customer);
            ContactBusinessRelation.SetFilter("No.", '<>%1', '');
            if ContactBusinessRelation.FindSet() then
                repeat
                    ClientTypeCustomer.Initialize(Customer);
                    ClientTypeCustomer.ValidateConstraints();
                    if Customer.Blocked <> "Customer Blocked"::" " then
                        Error(RelatedCustomerBlockedErr, _contact."No.", Customer."No.");
                until ContactBusinessRelation.Next() = 0;
        end;
    end;

    procedure AssignDefaults(var RentalHeader: Record "DEMO Rental Header")
    begin
        RentalHeader."Client Name" := _contact.Name;
        RentalHeader."E-Mail" := _contact."E-Mail";
        RentalHeader."Gen. Bus. Posting Group" := _contact."DEMO Gen. Bus. Posting Group";
        RentalHeader."Posting Group Mandatory" := _contact."DEMO Posting Group Mandatory";
    end;

    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin
        RentalJournalLine."Client Name" := _contact.Name;
        RentalJournalLine."E-Mail" := _contact."E-Mail";
        RentalJournalLine."Gen. Bus. Posting Group" := _contact."DEMO Gen. Bus. Posting Group";
        RentalJournalLine."Posting Group Mandatory" := _contact."DEMO Posting Group Mandatory";
    end;

    procedure AllowChangePostingGroupMandatory(): Boolean
    var
        ConfirmChangeQst: Label 'Changing Posting Group Mandatory is not recommended as it may affect posting. Do you want to continue?';
    begin
        if not Confirm(ConfirmChangeQst, false) then
            Error('');
        exit(true);
    end;

    procedure ValidatePostingRequirements()
    begin
        _contact.TestField(Type, "Contact Type"::"Person");
        _contact.TestField("Privacy Blocked", false);
        if _contact.Minor then
            _contact.TestField("Parental Consent Received");

        ValidateConstraints();
    end;
}
