using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class CampaignViewModel
    {
        public long ID { get; set; }

        public long SiteID { get; set; }

        public string SiteIDs { get; set; }

        public string Name { get; set; }

        public string Code { get; set; }

        public string Description { get; set; }

        public string CreatedBy { get; set; }

        public string ModifiedBy { get; set; }

        public DateTime DateCreated { get; set; }

        public DateTime? DateModified { get; set; }

        public bool Active { get; set; }

        public SiteViewModel SiteVM { get; set; }

        public string SiteName { get; set; }

        //public virtual ICollection<LoB> LoBs { get; set; }
    }
}
