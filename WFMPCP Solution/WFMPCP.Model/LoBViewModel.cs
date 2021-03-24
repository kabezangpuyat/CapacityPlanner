using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class LoBViewModel
    {
        public long ID { get; set; }

        public long CampaignID { get; set; }

        public string Name { get; set; }

        public string Code { get; set; }

        public string Description { get; set; }

        public string CreatedBy { get; set; }

        public string ModifiedBy { get; set; }

        public DateTime DateCreated { get; set; }

        public DateTime? DateModified { get; set; }

        public bool Active { get; set; }

        public CampaignViewModel CampaignVM { get; set; }

        public string SiteCampaignIds { get; set; }
        public string SiteCampaignLobIdDisplay { get; set; }
    }
}
