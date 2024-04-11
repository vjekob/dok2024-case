namespace Vjeko.Demos.Rental.Test;
using Vjeko.Demos.Rental;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;

codeunit 60022 "DEMO Test RentalJnl.-PostLine"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRental: Codeunit "DEMO Library - Rental";
        LibraryInventory: Codeunit "Library - Inventory";

    [Test]
    procedure Post_HappyPath()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        Customer: Record Customer;
        Item: Record Item;
        ItemUoM: Record "Item Unit of Measure";
        RentalJnlPostLine: Codeunit "DEMO Rental Jnl.-Post Line";
        RentalLedgEntry, RentalLedgEntry2 : Record "DEMO Rental Ledger Entry";
    begin
        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();
        RentalSetup."Maximum Balance (LCY)" := 100;
        RentalSetup.Modify();

        // [GIVEN] A customer
        LibraryRental.CreateCustomerWithEMail(Customer);

        // [GIVEN] An item
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemUnitOfMeasureCode(ItemUoM, Item."No.", 10);
        Item."DEMO Rental Unit of Measure" := ItemUoM."Code";
        Item.Modify();

        // [GIVEN] A rental journal line
        RentalJnlLine.Validate("Client Type", "DEMO Rental Client Type"::Customer);
        RentalJnlLine.Validate("Client No.", Customer."No.");
        RentalJnlLine.Validate("Posting Date", Today());
        RentalJnlLine.Validate(Type, "DEMO Rental Object Type"::Item);
        RentalJnlLine.Validate("No.", Item."No.");
        RentalJnlLine.Validate("Quantity", 1);

        // [GIVEN] Find last rental ledger entry, if it exists
        if RentalLedgEntry.FindLast() then;

        // [WHEN] A rental journal line is posted
        RentalJnlPostLine.Run(RentalJnlLine);

        // [THEN] A ledger entry is created
        if RentalLedgEntry2.FindLast() then;
        Assert.AreEqual(RentalLedgEntry."Entry No." + 1, RentalLedgEntry2."Entry No.", 'Ledger entry not created');
    end;

    [Test]
    procedure Post_EmptyLine_NoEntry()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalJnlPostLine: Codeunit "DEMO Rental Jnl.-Post Line";
        RentalLedgEntry, RentalLedgEntry2 : Record "DEMO Rental Ledger Entry";
    begin
        // [GIVEN] An empty rental journal line

        // [GIVEN] Find last rental ledger entry, if it exists
        if RentalLedgEntry.FindLast() then;

        // [WHEN] A rental journal line is posted
        RentalJnlPostLine.Run(RentalJnlLine);

        // [THEN] No ledger entry is created
        if RentalLedgEntry2.FindLast() then;
        Assert.AreEqual(RentalLedgEntry."Entry No.", RentalLedgEntry2."Entry No.", 'Ledger entry not created');
    end;

    [Test]
    procedure CheckLine_EmptyLine_Exits()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An empty rental journal line

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] No error has occurred
    end;

    [Test]
    procedure CheckLine_NoClientNo_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine.Quantity := 1;

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("Client No."));
    end;

    [Test]
    procedure CheckLine_NoNo_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine.Quantity := 1;

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("No."));
    end;

    [Test]
    procedure CheckLine_NoPostingDate_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine.Quantity := 1;

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("Posting Date"));
    end;

    [Test]
    procedure CheckLine_NoQuantity_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("Quantity"));
    end;

    [Test]
    procedure CheckLine_NoUnitOfMeasureCode_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine.Quantity := 1;

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("Unit of Measure Code"));
    end;

    [Test]
    procedure CheckLine_NoEMail_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."Unit of Measure Code" := '10';

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("E-Mail"));
    end;

    [Test]
    procedure CheckLine_NoGenBusPostingGroup_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine."E-Mail" := 'test@dummy.com';

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("Gen. Bus. Posting Group"));
    end;

    [Test]
    procedure CheckLine_GenProductPostingGroup_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine."E-Mail" := 'test@dummy.com';
        RentalJnlLine."Gen. Bus. Posting Group" := 'TEST';

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), RentalJnlLine.FieldCaption("Gen. Product Posting Group"));
    end;

    [Test]
    procedure CheckLine_InvalidTypeCombination_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine."E-Mail" := 'test@dummy.com';
        RentalJnlLine."Gen. Bus. Posting Group" := 'TEST';
        RentalJnlLine."Gen. Product Posting Group" := 'TEST';

        // [GIVEN] Invalid type combination
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Contact;
        RentalJnlLine.Type := "DEMO Rental Object Type"::FixedAsset;
        // TODO Do we test other combinations? 🤔
        //      The answer is NO, we have better ways to test this stuff.
        //      We shouldn't even test this one, not this way, anyway.

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('Dialog');
        Assert.IsSubstring(GetLastErrorText(), 'Invalid client type/object type combination');
    end;

    [Test]
    procedure CheckLine_InvalidQuantity()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] An rental journal line
        RentalJnlLine."Client No." := '10000';
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine."E-Mail" := 'test@dummy.com';
        RentalJnlLine."Gen. Bus. Posting Group" := 'TEST';
        RentalJnlLine."Gen. Product Posting Group" := 'TEST';

        // [GIVEN] Invalid quantity combination
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Contact;
        RentalJnlLine.Type := "DEMO Rental Object Type"::Resource;
        RentalJnlLine.Quantity := -1;
        // TODO Do we test other combinations? 🤔
        //      The answer is NO, we have better ways to test this stuff.
        //      We shouldn't even test this one, not this way, anyway.

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('Dialog');
        Assert.IsSubstring(GetLastErrorText(), 'Invalid quantity for client type/object type combination');
    end;

    [Test]
    procedure CheckLine_Customer_Blocked_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        Customer: Record Customer;
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] A customer
        LibraryRental.CreateCustomerWithEMail(Customer);
        Customer.Blocked := "Customer Blocked"::All;
        Customer.Modify();

        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := Customer."No.";
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."E-Mail" := 'test@dummy.com';
        RentalJnlLine."Gen. Bus. Posting Group" := 'TEST';
        RentalJnlLine."Gen. Product Posting Group" := 'TEST';

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption(Blocked));
    end;

    [Test]
    procedure CheckLine_Customer_ExceedsBalance_Error()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        Customer: Record Customer;
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] A customer
        LibraryRental.CreateCustomerWithEMail(Customer);

        // [GIVEN] Balance for customer
        LibraryRental.CreateCustomerBalance(Customer, 100);

        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := Customer."No.";
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."E-Mail" := 'test@dummy.com';
        RentalJnlLine."Gen. Bus. Posting Group" := 'TEST';
        RentalJnlLine."Gen. Product Posting Group" := 'TEST';

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();
        RentalSetup."Maximum Balance (LCY)" := 50;
        RentalSetup.Modify();

        // [WHEN] A rental journal line is checked
        asserterror RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] An error has occurred
        Assert.ExpectedErrorCode('Dialog');
        Assert.IsSubstring(GetLastErrorText(), 'outstanding balance exceeds the maximum allowed limit');
    end;

    [Test]
    procedure CheckLine_Customer_OK()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalSetup: Record "DEMO Rental Setup";
        Customer: Record Customer;
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
    begin
        // [GIVEN] A customer
        LibraryRental.CreateCustomerWithEMail(Customer);

        // [GIVEN] An rental journal line
        RentalJnlLine."Client Type" := "DEMO Rental Client Type"::Customer;
        RentalJnlLine."Client No." := Customer."No.";
        RentalJnlLine."No." := '10000';
        RentalJnlLine."Posting Date" := Today();
        RentalJnlLine."Unit of Measure Code" := '10';
        RentalJnlLine.Quantity := 1;
        RentalJnlLine."E-Mail" := 'test@dummy.com';
        RentalJnlLine."Gen. Bus. Posting Group" := 'TEST';
        RentalJnlLine."Gen. Product Posting Group" := 'TEST';

        // [GIVEN] Rental Setup
        if not RentalSetup.Get() then
            RentalSetup.Insert();
        RentalSetup."Maximum Balance (LCY)" := 50;
        RentalSetup.Modify();

        // [WHEN] A rental journal line is checked
        RentalJnlCheckLine.Run(RentalJnlLine);

        // [THEN] No error has occurred
    end;
}