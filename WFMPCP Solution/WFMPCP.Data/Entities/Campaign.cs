using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class Campaign
    {
        public long ID { get; set; }

        public long SiteID { get; set; }

        public string Name { get; set; }

        public string Code { get; set; }

        public string Description { get; set; }

        public string CreatedBy { get; set; }

        public string ModifiedBy { get; set; }

        public DateTime DateCreated { get; set; }

        public DateTime? DateModified { get; set; }

        public bool Active { get; set; }

		#region Virtual
		public virtual Site Site { get; set; }

		public virtual ICollection<LoB> LoBs { get; set; }

		public virtual ICollection<WeeklyDatapoint> WeeklyDatapoints { get; set; }
		public virtual ICollection<WeeklyDatapointLog> WeeklyDatapointLogs { get; set; }
		public virtual ICollection<WeeklyStaffDatapoint> WeeklyStaffDatapoints { get; set; }
		public virtual ICollection<WeeklyHiringDatapoint> WeeklyHiringDatapoints { get; set; }
		public virtual ICollection<WeeklySummaryDatapoint> WeeklySummaryDatapoints { get; set; }
		public virtual ICollection<SiteCampaign> SiteCampaigns { get; set; }
		public virtual ICollection<SiteCampaignLoB> SiteCampaignLoBs { get; set; }
		public virtual ICollection<SiteCampaignLobFormula> SiteCampaignLoBFormulas { get; set; }
		#endregion
	}
}
