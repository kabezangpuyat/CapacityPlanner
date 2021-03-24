using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class WeeklyDatapointViewModel
    {
        public long ID { get; set; }
        public long? SiteID { get; set; }
        public long? CampaignID { get; set; }
        public long? LoBID { get; set; }
        public long DatapointID { get; set; }
        public int Week { get; set; }
        public string Datatype { get; set; }
        public string Data { get; set; }
        public DateTime Date { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateModified { get; set; }

        public CampaignViewModel CampaignVM { get; set; }
        public LoBViewModel LoBVM { get; set; }
        public DatapointViewModel DatapointVM { get; set; }
    }
}
