namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;

codeunit 50031 "DEMO Rental Client - Customer" implements "DEMO Rental Client Type"
{
    var
        _customer: Record Customer;

    procedure Initialize(Customer: Record Customer)
    begin
        _customer := Customer;
    end;

    procedure Initialize(No: Code[20])
    begin
        _customer.SetAutoCalcFields("Balance Due (LCY)");
        _customer.Get(No);
    end;

    procedure ValidateRequirements()
    begin
        _customer.TestField(Blocked, "Customer Blocked"::" ");
        _customer.TestField("E-Mail");
        _customer.TestField("Customer Posting Group");
        _customer.TestField("Gen. Bus. Posting Group");
        _customer.TestField("VAT Bus. Posting Group");
        _customer.TestField("Payment Terms Code");
    end;

    procedure HasConstraints(): Boolean
    begin
        exit(true);
    end;

    procedure ValidateConstraints(): Boolean
    var
        RentalSetup: Record "DEMO Rental Setup";
        MaximumBalanceExceededErr: Label 'Unable to proceed with rental for customer %1: outstanding balance exceeds the maximum allowed limit.', Comment = '%1 is customer no.';
    begin
        RentalSetup.Get();
        RentalSetup.TestField("Maximum Balance (LCY)");
        _customer.CalcFields("Balance Due (LCY)");
        if _customer."Balance Due (LCY)" > RentalSetup."Maximum Balance (LCY)" then
            Error(MaximumBalanceExceededErr, _customer."No.");
    end;

    procedure AssignDefaults(var RentalHeader: Record "DEMO Rental Header")
    begin
        RentalHeader."Client Name" := _customer.Name;
        RentalHeader."E-Mail" := _customer."E-Mail";
        RentalHeader."Gen. Bus. Posting Group" := _customer."Gen. Bus. Posting Group";
    end;

    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin
        RentalJournalLine."Client Name" := _customer.Name;
        RentalJournalLine."E-Mail" := _customer."E-Mail";
        RentalJournalLine."Gen. Bus. Posting Group" := _customer."Gen. Bus. Posting Group";
    end;

    procedure AllowChangePostingGroupMandatory(): Boolean
    begin
        exit(false);
    end;

    procedure ValidatePostingRequirements()
    begin
        _customer.TestField(Blocked, "Customer Blocked"::" ");
        ValidateConstraints();
    end;

    procedure CanChangeClientName(var RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        exit(true);
    end;

    procedure CanChangeClientName(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        exit(true);
    end;

    procedure CanChangeEMail(var RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        exit(true);
    end;

    procedure CanChangeEMail(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        exit(true);
    end;

    procedure CanChangeGenBusPostingGroup(var RentalHeader: Record "DEMO Rental Header"): Boolean
    begin
        exit(true);
    end;

    procedure CanChangeGenBusPostingGroup(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        exit(true);
    end;

    procedure AcceptsObjectType(var RentalLine: Record "DEMO Rental Line"): Boolean
    begin
        if RentalLine.Type = "DEMO Rental Object Type"::FixedAsset then
            exit(false);

        exit(true);
    end;

    procedure AcceptsObjectType(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJnlLine.Type = "DEMO Rental Object Type"::FixedAsset then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"): Boolean
    begin
        if RentalLine.Type <> "DEMO Rental Object Type"::Resource then
            exit(true);

        if RentalLine.Quantity < 0 then
            exit(false);

        exit(true);
    end;

    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin
        if RentalJnlLine.Type <> "DEMO Rental Object Type"::Resource then
            exit(true);

        if RentalJnlLine.Quantity < 0 then
            exit(false);

        exit(true);
    end;
}
