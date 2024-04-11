namespace Vjeko.Demos.Rental.Test;

using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 60020 "DEMO Library - Rental"
{
    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateCustomerWithEMail(var Customer: Record Customer): Code[20]
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer."E-Mail" := 'test@dummy.com';
        Customer.Modify(false);
        exit(Customer."No.");
    end;

    procedure CreateCustomerBalance(var Customer: Record Customer; Balance: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlLine.Validate("Posting Date", WorkDate());
        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Invoice);
        GenJnlLine.Validate("Document No.", LibraryUtility.GetNextNoFromNoSeries(LibraryUtility.GetGlobalNoSeriesCode(), WorkDate()));
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.Validate("Account No.", Customer."No.");
        GenJnlLine.Validate(Amount, Balance);

        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;
}
