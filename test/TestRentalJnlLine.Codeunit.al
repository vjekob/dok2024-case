namespace Vjeko.Demos.Rental.Test;

using Vjeko.Demos.Rental;
using Microsoft.Sales.Customer;

codeunit 60021 "DEMO Test Rental Jnl. Line"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRental: Codeunit "DEMO Library - Rental";

    [Test]
    procedure ClientNo_OnValidate_Customer_Blocked()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
    begin
        // [GIVEN] A blocked customer
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer.Blocked := "Customer Blocked"::All;
        Customer.Modify(false);

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption(Blocked));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_NoEmail()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
    begin
        // [GIVEN] A customer without e-mail
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer."E-Mail" := '';
        Customer.Modify(false);

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("E-Mail"));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_NoCustomerPostingGroup()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
    begin
        // [GIVEN] Customer without a customer posting group
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer."Customer Posting Group" := '';
        Customer.Modify(false);

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("Customer Posting Group"));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_NoGenBusPostingGroup()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
    begin
        // [GIVEN] Customer without a general business posting group
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer."Gen. Bus. Posting Group" := '';
        Customer.Modify(false);

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("Gen. Bus. Posting Group"));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_NoVATBusPostingGroup()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
    begin
        // [GIVEN] Customer without a VAT business posting group
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer."VAT Bus. Posting Group" := '';
        Customer.Modify(false);

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("VAT Bus. Posting Group"));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_NoPaymentTermsCode()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
    begin
        // [GIVEN] Customer without payment terms code
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer."Payment Terms Code" := '';
        Customer.Modify(false);

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("Payment Terms Code"));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_NoMaximumBalance()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
        RentalSetup: Record "DEMO Rental Setup";
    begin
        // [GIVEN] Customer correctly set up
        LibraryRental.CreateCustomerWithEMail(Customer);

        // [GIVEN] Rental setup record without maximum balance
        RentalSetup."Maximum Balance (LCY)" := 0;
        if not RentalSetup.Modify() then
            RentalSetup.Insert();

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Testfield fails
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalSetup.FieldCaption("Maximum Balance (LCY)"));
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_ExceedsMaximumBalance()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
        RentalSetup: Record "DEMO Rental Setup";
    begin
        // [GIVEN] Customer correctly set up, with balance
        LibraryRental.CreateCustomerWithEMail(Customer);
        LibraryRental.CreateCustomerBalance(Customer, 200);

        // [GIVEN] Rental setup record with maximum balance
        RentalSetup."Maximum Balance (LCY)" := 100;
        if not RentalSetup.Modify() then
            RentalSetup.Insert();

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        asserterror RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Validation fails
        Assert.ExpectedErrorCode('Dialog');
        Assert.IsSubstring(GetLastErrorText(), 'outstanding balance exceeds the maximum allowed limit');
    end;

    [Test]
    procedure ClientNo_OnValidate_Customer_OK()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Customer: Record Customer;
        RentalSetup: Record "DEMO Rental Setup";
    begin
        // [GIVEN] Customer correctly set up
        LibraryRental.CreateCustomerWithEMail(Customer);

        // [GIVEN] Rental setup record with maximum balance
        RentalSetup."Maximum Balance (LCY)" := 100;
        if not RentalSetup.Modify() then
            RentalSetup.Insert();

        // [GIVEN] A header of type Customer
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;

        // [WHEN] Validating Client No.
        RentalJnlLine.Validate("Client No.", Customer."No.");

        // [THEN] Assigned correct values
        Assert.AreEqual(Customer.Name, RentalJnlLine."Client Name", 'Client Name not assigned correctly');
        Assert.AreEqual(Customer."E-Mail", RentalJnlLine."E-Mail", 'Client E-Mail not assigned correctly');
        Assert.AreEqual(Customer."Gen. Bus. Posting Group", RentalJnlLine."Gen. Bus. Posting Group", 'Gen. Bus. Posting Group not assigned correctly');
        Assert.AreEqual(false, RentalJnlLine."Posting Group Mandatory", 'Posting Group Mandatory not assigned correctly');
    end;
}
