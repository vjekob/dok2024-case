namespace Vjeko.Demos.Rental;

using Microsoft.Inventory.Item;

tableextension 50004 "DEMO Item Ext." extends Item
{
    fields
    {
        field(50000; "DEMO Rental Unit of Measure"; Code[10])
        {
            Caption = 'Rental Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
        }
    }
}
