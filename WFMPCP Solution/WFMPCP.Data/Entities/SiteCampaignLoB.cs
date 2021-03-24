using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class SiteCampaignLoB
    {
        public long ID { get; set; }
        public long SiteID { get; set; }
        public long CampaignID { get; set; }
        public long LoBID { get; set; }

        public bool Active { get; set; }

        public virtual Site Site { get; set; }
        public virtual Campaign Campaign { get; set; }
        public virtual LoB LoB { get; set; }
    }
}
