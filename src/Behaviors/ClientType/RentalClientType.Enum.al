namespace Vjeko.Demos.Rental;
using Vjeko.Demos.Rental.Test;

enum 50002 "DEMO Rental Client Type" implements "DEMO Rental Client Type"
{
    Caption = 'Rental Client Type';
    Extensible = true;

    value(0; Customer)
    {
        Caption = 'Customer';
        Implementation = "DEMO Rental Client Type" = "DEMO Rental Client - Customer";
    }

    value(1; Contact)
    {
        Caption = 'Contact';
        Implementation = "DEMO Rental Client Type" = "DEMO Rental Client - Contact";
    }

    value(2; Employee)
    {
        Caption = 'Employee';
        Implementation = "DEMO Rental Client Type" = "DEMO Rental Client - Employee";
    }

    /// <summary>
    /// This would otherwise be in an enum extension. I apologize for my demo container
    /// being on runtime 12, instead of 13. So I have to do it like this...
    /// </summary>
    value(999; Mock)
    {
        Caption = 'Mock';
        Implementation = "DEMO Rental Client Type" = Vjeko.Demos.Rental.Test."DEMO Rental Client - Mock";
    }
}
