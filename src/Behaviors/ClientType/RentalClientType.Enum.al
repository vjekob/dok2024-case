namespace Vjeko.Demos.Rental;

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
}
