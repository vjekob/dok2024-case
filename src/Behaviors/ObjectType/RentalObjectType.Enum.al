namespace Vjeko.Demos.Rental;

enum 50003 "DEMO Rental Object Type" implements "DEMO Rental Object Type"
{
    Caption = 'Rental Object Type';
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
        Implementation = "DEMO Rental Object Type" = "DEMO Rental Object - Item";
    }

    value(1; FixedAsset)
    {
        Caption = 'Fixed Asset';
        Implementation = "DEMO Rental Object Type" = "DEMO Rental Object - FA";
    }

    value(2; Resource)
    {
        Caption = 'Resource';
        Implementation = "DEMO Rental Object Type" = "DEMO Rental Object - Resource";
    }
}
