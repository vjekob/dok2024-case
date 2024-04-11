namespace Vjeko.Demos.Rental;

using Microsoft.Sales.Customer;

codeunit 50026 "DEMO Rental Jnl.-Post Line"
{
    Permissions = tabledata "DEMO Rental Ledger Entry" = rimd;
    TableNo = "DEMO Rental Journal Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        RentalJnlLine: Record "DEMO Rental Journal Line";
        RentalLedgEntry: Record "DEMO Rental Ledger Entry";
        RentalLedgEntry2: Record "DEMO Rental Ledger Entry";
        Customer: Record Customer;
        RentalJnlCheckLine: Codeunit "DEMO Rental Jnl.-Check Line";
        NextEntryNo: Integer;

    procedure RunWithCheck(var RentalJnlLine2: Record "DEMO Rental Journal Line")
    begin
        RentalJnlLine.Copy(RentalJnlLine2);
        Code();
        RentalJnlLine2 := RentalJnlLine;
    end;

    local procedure "Code"()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostResJnlLine(RentalJnlLine, IsHandled);
        if not IsHandled then begin
            if RentalJnlLine.EmptyLine() then
                exit;

            RentalJnlCheckLine.RunCheck(RentalJnlLine);

            if NextEntryNo = 0 then begin
                RentalLedgEntry.LockTable();
                NextEntryNo := RentalLedgEntry.GetLastEntryNo() + 1;
            end;

            RentalLedgEntry.Init();
            RentalLedgEntry."Entry No." := NextEntryNo;
            RentalLedgEntry.CopyFromRentalJnlLine(RentalJnlLine);
            RentalLedgEntry.Insert(true);

            NextEntryNo := NextEntryNo + 1;
        end;

        OnAfterCode(RentalLedgEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostResJnlLine(var RentalJnlLine: Record "DEMO Rental Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var RentalLedgEntry: Record "DEMO Rental Ledger Entry")
    begin
    end;

}