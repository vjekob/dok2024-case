namespace Vjeko.Demos.Rental.Test;
using Vjeko.Demos.Rental;

codeunit 60026 "DEMO Rental Client - Mock" implements "DEMO Rental Client Type"
{
    EventSubscriberInstance = Manual;

    procedure Initialize(No: Code[20])
    begin

    end;

    procedure ValidateRequirements()
    begin

    end;

    procedure ValidatePostingRequirements()
    begin

    end;

    procedure HasConstraints(): Boolean
    begin

    end;

    procedure ValidateConstraints(): Boolean
    begin

    end;

    procedure AssignDefaults(var RentalHeader: Record "DEMO Rental Header")
    begin

    end;

    procedure AssignDefaults(var RentalJournalLine: Record "DEMO Rental Journal Line")
    begin

    end;

    procedure AllowChangePostingGroupMandatory(): Boolean
    begin

    end;

    var
        _result_CanChangeClientName: Boolean;

    procedure CanChangeClientName(var RentalHeader: Record "DEMO Rental Header") Result: Boolean
    begin
        OnCanChangeClientName(Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCanChangeClientName(var Result: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DEMO Rental Client - Mock", OnCanChangeClientName, '', false, false)]
    local procedure Subscribe_OnCanChangeClientName(var Result: Boolean)
    begin
        Result := _result_CanChangeClientName;
    end;

    procedure SetResult_CanChangeClientName(Value: Boolean)
    begin
        _result_CanChangeClientName := Value;
    end;

    procedure CanChangeClientName(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin

    end;

    procedure CanChangeEMail(var RentalHeader: Record "DEMO Rental Header"): Boolean
    begin

    end;

    procedure CanChangeEMail(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin

    end;

    procedure CanChangeGenBusPostingGroup(var RentalHeader: Record "DEMO Rental Header"): Boolean
    begin

    end;

    procedure CanChangeGenBusPostingGroup(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin

    end;

    procedure AcceptsObjectType(var RentalLine: Record "DEMO Rental Line"): Boolean
    begin

    end;

    procedure AcceptsObjectType(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin

    end;

    procedure AcceptsQuantity(var RentalLine: Record "DEMO Rental Line"): Boolean
    begin

    end;

    procedure AcceptsQuantity(var RentalJnlLine: Record "DEMO Rental Journal Line"): Boolean
    begin

    end;
}