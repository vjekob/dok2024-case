namespace Vjeko.Demos.Rental;

enum 50002 "DEMO Rental Client Type"
{
    Caption = 'Rental Client Type';
    Extensible = true;

    value(0; Customer)
    {
        Caption = 'Customer';
    }

    value(1; Contact)
    {
        Caption = 'Contact';
    }

    value(2; Employee)
    {
        Caption = 'Employee';
    }
}
