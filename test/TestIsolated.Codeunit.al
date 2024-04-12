namespace Vjeko.Demos.Rental.Test;

using Vjeko.Demos.Rental;

codeunit 60027 "DEMO Test Isolated"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure Example_RentalHeader_CanChangeClientName_Allowed()
    var
        RentalHeader: Record "DEMO Rental Header";
        Mock: Codeunit "DEMO Rental Client - Mock";
    begin
        Mock.SetResult_CanChangeClientName(true);
        BindSubscription(Mock);

        RentalHeader."Client Type" := "DEMO Rental Client Type"::Mock;
        RentalHeader.Validate("Client Name", 'dummy');
    end;

    [Test]
    procedure Example_RentalHeader_CanChangeClientName_Denied()
    var
        RentalHeader: Record "DEMO Rental Header";
        Mock: Codeunit "DEMO Rental Client - Mock";
    begin
        Mock.SetResult_CanChangeClientName(false);
        BindSubscription(Mock);

        RentalHeader."Client Type" := "DEMO Rental Client Type"::Mock;
        asserterror RentalHeader.Validate("Client Name", 'dummy');

        Assert.ExpectedErrorCode('NCLCSRTS:TableErrorStr');
        Assert.IsSubstring(GetLastErrorText(), RentalHeader.FieldCaption("Client Type"));
    end;
}
