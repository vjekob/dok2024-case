namespace Vjeko.Demos.Rental.Test;

using Microsoft.Sales.Customer;
using Vjeko.Demos.Rental;

codeunit 60025 "DEMO Test Customer"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRental: Codeunit "DEMO Library - Rental";

    [Test]
    procedure ValidateRequirements_Blocked()
    var
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer.Blocked := "Customer Blocked"::All;
        Client.Initialize(Customer);

        asserterror Client.ValidateRequirements();

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption(Blocked));
    end;

    [Test]
    procedure ValidateRequirements_EMail()
    var
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer."E-Mail" := '';
        Client.Initialize(Customer);

        asserterror Client.ValidateRequirements();

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("E-Mail"));
    end;

    [Test]
    procedure ValidateRequirements_CustomerPostingGroup()
    var
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer."E-Mail" := 'dummy@dummy.ai';
        Customer."Customer Posting Group" := '';
        Client.Initialize(Customer);

        asserterror Client.ValidateRequirements();

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("Customer Posting Group"));
    end;

    [Test]
    procedure ValidateRequirements_GenBusPostingGroup()
    var
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer."E-Mail" := 'dummy@dummy.ai';
        Customer."Customer Posting Group" := 'DUMMY';
        Customer."Gen. Bus. Posting Group" := '';
        Client.Initialize(Customer);

        asserterror Client.ValidateRequirements();

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("Gen. Bus. Posting Group"));
    end;

    [Test]
    procedure ValidateRequirements_VATBusPostingGroup()
    var
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer."E-Mail" := 'dummy@dummy.ai';
        Customer."Customer Posting Group" := 'DUMMY';
        Customer."Gen. Bus. Posting Group" := 'DUMMY';
        Customer."VAT Bus. Posting Group" := '';
        Client.Initialize(Customer);

        asserterror Client.ValidateRequirements();

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("VAT Bus. Posting Group"));
    end;

    [Test]
    procedure ValidateRequirements_PaymentTermsCode()
    var
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer."E-Mail" := 'dummy@dummy.ai';
        Customer."Customer Posting Group" := 'DUMMY';
        Customer."Gen. Bus. Posting Group" := 'DUMMY';
        Customer."VAT Bus. Posting Group" := 'DUMMY';
        Customer."Payment Terms Code" := '';
        Client.Initialize(Customer);

        asserterror Client.ValidateRequirements();

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Customer.FieldCaption("Payment Terms Code"));
    end;

    [Test]
    procedure HasConstraints()
    var
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.HasConstraints(), 'True expected');
    end;

    [Test]
    procedure ValidateConstraints_ExceedsBalance()
    var
        RentalSetup: Record "DEMO Rental Setup";
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        // [GIVEN] Customer with balance
        LibraryRental.CreateCustomerWithEMail(Customer);
        LibraryRental.CreateCustomerBalance(Customer, 200);
        Client.Initialize(Customer);

        // [GIVEN] Rental setup record with maximum balance
        RentalSetup."Maximum Balance (LCY)" := 100;
        if not RentalSetup.Modify() then
            RentalSetup.Insert();

        asserterror Client.ValidateConstraints();

        Assert.ExpectedErrorCode('Dialog');
        Assert.IsSubstring(GetLastErrorText(), 'outstanding balance exceeds the maximum allowed limit');
    end;

    [Test]
    procedure ValidateConstraints_BalanceOK()
    var
        RentalSetup: Record "DEMO Rental Setup";
        Customer: Record Customer;
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        // [GIVEN] Customer with balance
        LibraryRental.CreateCustomerWithEMail(Customer);
        Client.Initialize(Customer);

        // [GIVEN] Rental setup record with maximum balance
        RentalSetup."Maximum Balance (LCY)" := 100;
        if not RentalSetup.Modify() then
            RentalSetup.Insert();

        Client.ValidateConstraints();
    end;

    [Test]
    procedure AssignDefaults_RentalHeader()
    var
        Customer: Record Customer;
        RentalHeader: Record "DEMO Rental Header";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer.Name := 'Test Customer';
        Customer."E-Mail" := 'dummy@dummy.ai';
        Customer."Gen. Bus. Posting Group" := 'DUMMY';
        Client.Initialize(Customer);

        Client.AssignDefaults(RentalHeader);

        Assert.AreEqual(Customer.Name, RentalHeader."Client Name", 'Client Name not assigned correctly');
        Assert.AreEqual(Customer."E-Mail", RentalHeader."E-Mail", 'E-Mail not assigned correctly');
        Assert.AreEqual(Customer."Gen. Bus. Posting Group", RentalHeader."Gen. Bus. Posting Group", 'Gen. Bus. Posting Group not assigned correctly');
    end;

    [Test]
    procedure AssignDefaults_RentalJournalLine()
    var
        Customer: Record Customer;
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Customer.Name := 'Test Customer';
        Customer."E-Mail" := 'dummy@dummy.ai';
        Customer."Gen. Bus. Posting Group" := 'DUMMY';
        Client.Initialize(Customer);

        Client.AssignDefaults(RentalJnlLine);

        Assert.AreEqual(Customer.Name, RentalJnlLine."Client Name", 'Client Name not assigned correctly');
        Assert.AreEqual(Customer."E-Mail", RentalJnlLine."E-Mail", 'E-Mail not assigned correctly');
        Assert.AreEqual(Customer."Gen. Bus. Posting Group", RentalJnlLine."Gen. Bus. Posting Group", 'Gen. Bus. Posting Group not assigned correctly');
    end;

    [Test]
    procedure AllowChangePostingGroupMandatory()
    var
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsFalse(Client.AllowChangePostingGroupMandatory(), 'False expected');
    end;

    [Test]
    procedure CanChangeClientName_RentalHeader()
    var
        RentalHeader: Record "DEMO Rental Header";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.CanChangeClientName(RentalHeader), 'True expected');
    end;

    [Test]
    procedure CanChangeClientName_RentalJournalLine()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.CanChangeClientName(RentalJnlLine), 'True expected');
    end;

    [Test]
    procedure CanChangeEMail_RentalHeader()
    var
        RentalHeader: Record "DEMO Rental Header";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.CanChangeEMail(RentalHeader), 'True expected');
    end;

    [Test]
    procedure CanChangeEMail_RentalJournalLine()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.CanChangeEMail(RentalJnlLine), 'True expected');
    end;

    [Test]
    procedure CanChangeGenBusPostingGroup_RentalHeader()
    var
        RentalHeader: Record "DEMO Rental Header";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.CanChangeGenBusPostingGroup(RentalHeader), 'True expected');
    end;

    [Test]
    procedure CanChangeGenBusPostingGroup_RentalJournalLine()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
    begin
        Assert.IsTrue(Client.CanChangeGenBusPostingGroup(RentalJnlLine), 'True expected');
    end;

    [Test]
    procedure AcceptsObjectType_RentalLine()
    var
        RentalLine: Record "DEMO Rental Line";
        Client: Codeunit "DEMO Rental Client - Customer";
        ObjectType: Enum "DEMO Rental Object Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"DEMO Rental Object Type".Ordinals() do begin
            ObjectType := Enum::"DEMO Rental Object Type".FromInteger(Ordinal);
            RentalLine.Type := ObjectType;
            case ObjectType of
                ObjectType::FixedAsset:
                    Assert.IsFalse(Client.AcceptsObjectType(RentalLine), 'False expected for Fixed Asset');
                else
                    Assert.IsTrue(Client.AcceptsObjectType(RentalLine), 'True expected for ' + Format(ObjectType));
            end;
        end;
    end;

    [Test]
    procedure AcceptsObjectType_RentalJournalLine()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
        ObjectType: Enum "DEMO Rental Object Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"DEMO Rental Object Type".Ordinals() do begin
            ObjectType := Enum::"DEMO Rental Object Type".FromInteger(Ordinal);
            RentalJnlLine.Type := ObjectType;
            case ObjectType of
                ObjectType::FixedAsset:
                    Assert.IsFalse(Client.AcceptsObjectType(RentalJnlLine), 'False expected for Fixed Asset');
                else
                    Assert.IsTrue(Client.AcceptsObjectType(RentalJnlLine), 'True expected for ' + Format(ObjectType));
            end;
        end;
    end;

    [Test]
    procedure AcceptsQuantity_RentalLine_GreaterOrEqual_Zero()
    var
        RentalLine: Record "DEMO Rental Line";
        Client: Codeunit "DEMO Rental Client - Customer";
        ObjectType: Enum "DEMO Rental Object Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"DEMO Rental Object Type".Ordinals() do begin
            ObjectType := Enum::"DEMO Rental Object Type".FromInteger(Ordinal);
            Assert.IsTrue(Client.AcceptsQuantity(RentalLine), 'True expected for ' + Format(ObjectType));
        end;
    end;

    [Test]
    procedure AcceptsQuantity_RentalJournalLine_GreaterOrEqual_Zero()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
        ObjectType: Enum "DEMO Rental Object Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"DEMO Rental Object Type".Ordinals() do begin
            ObjectType := Enum::"DEMO Rental Object Type".FromInteger(Ordinal);
            Assert.IsTrue(Client.AcceptsQuantity(RentalJnlLine), 'True expected for ' + Format(ObjectType));
        end;
    end;

    [Test]
    procedure AcceptsQuantity_RentalLine_LessThan_Zero()
    var
        RentalLine: Record "DEMO Rental Line";
        Client: Codeunit "DEMO Rental Client - Customer";
        ObjectType: Enum "DEMO Rental Object Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"DEMO Rental Object Type".Ordinals() do begin
            ObjectType := Enum::"DEMO Rental Object Type".FromInteger(Ordinal);
            RentalLine.Type := ObjectType;
            RentalLine.Quantity := -1;
            case ObjectType of
                ObjectType::Resource:
                    Assert.IsFalse(Client.AcceptsQuantity(RentalLine), 'False expected for Resource');
                else
                    Assert.IsTrue(Client.AcceptsQuantity(RentalLine), 'True expected for ' + Format(ObjectType));
            end;
        end;
    end;

    [Test]
    procedure AcceptsQuantity_RentalJournalLine_LessThan_Zero()
    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        Client: Codeunit "DEMO Rental Client - Customer";
        ObjectType: Enum "DEMO Rental Object Type";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"DEMO Rental Object Type".Ordinals() do begin
            ObjectType := Enum::"DEMO Rental Object Type".FromInteger(Ordinal);
            RentalJnlLine.Type := ObjectType;
            RentalJnlLine.Quantity := -1;
            case ObjectType of
                ObjectType::Resource:
                    Assert.IsFalse(Client.AcceptsQuantity(RentalJnlLine), 'False expected for Resource');
                else
                    Assert.IsTrue(Client.AcceptsQuantity(RentalJnlLine), 'True expected for ' + Format(ObjectType));
            end;
        end;
    end;

}