namespace Vjeko.Demos.Rental;

using Microsoft.CRM.Contact;
using Microsoft.Finance.GeneralLedger.Setup;

tableextension 50003 "DEMO Contact Ext." extends Contact
{
    fields
    {
        field(50000; "DEMO Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Business Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }

        field(50001; "DEMO Posting Group Mandatory"; Boolean)
        {
            Caption = 'Posting Group Mandatory';
        }
    }
}
