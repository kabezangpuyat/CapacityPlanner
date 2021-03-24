using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class SiteCampaignLoBViewModel
    {
        public SiteViewModel SiteVM { get; set; }
        public CampaignViewModel CampaignVM { get; set; }
        public LoBViewModel LobVM { get; set; }

        public long ID { get; set; }

        public long SiteID { get; set; }
        public long CampaignID { get; set; }
        public long LobID { get; set; }
        public bool Active { get; set; }
    }
}
