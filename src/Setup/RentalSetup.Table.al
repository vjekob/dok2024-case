namespace Vjeko.Demos.Rental;
using Microsoft.Finance.GeneralLedger.Setup;

table 50008 "DEMO Rental Setup"
{
    Caption = 'Rental Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }

        field(2; "Maximum Balance (LCY)"; Decimal)
        {
            Caption = 'Maximum Balance (LCY)';
        }

        field(3; "Employee Gen.Bus.Posting Group"; Code[20])
        {
            Caption = 'Employee Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }

        field(4; "FA Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Fixed Asset Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
    }
}
