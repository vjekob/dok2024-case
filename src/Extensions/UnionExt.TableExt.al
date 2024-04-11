namespace Vjeko.Demos.Rental;

using Microsoft.HumanResources.Setup;

tableextension 50002 "DEMO Union Ext." extends Union
{
    fields
    {
        field(50000; "DEMO Rental Allowed"; Boolean)
        {
            Caption = 'Rental Allowed';
            DataClassification = CustomerContent;
        }
    }
}
