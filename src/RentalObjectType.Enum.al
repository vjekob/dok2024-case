namespace Vjeko.Demos.Rental;

enum 50003 "DEMO Rental Object Type"
{
    Caption = 'Rental Object Type';
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }

    value(1; FixedAsset)
    {
        Caption = 'Fixed Asset';
    }

    value(2; Resource)
    {
        Caption = 'Resource';
    }
}
