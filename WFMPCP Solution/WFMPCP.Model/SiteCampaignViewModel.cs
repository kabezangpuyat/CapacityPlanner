using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class SiteCampaignViewModel
    {
        public SiteViewModel SiteVM { get; set; }
        public CampaignViewModel CampaignVM { get; set; }

        public bool Active { get; set; }

        public long ID { get; set; }

        public long SiteID { get; set; }

        public long CampaignID { get; set; }
    }
}
