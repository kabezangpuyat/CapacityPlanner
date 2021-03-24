using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
	public class SiteCampaignLobFormulaViewModel
	{
		public long ID { get; set; }
		public long SiteID { get; set; }
		public long CampaignID { get; set; }
		public long LoBID { get; set; }
		public long DynamicFormulaID { get; set; }
		public DateTime DateCreated { get; set; }
		public DateTime? DateModified { get; set; }
		public bool Active { get; set; }

		public SiteViewModel SiteVM { get; set; }
		public LoBViewModel LoBVM { get; set; }
		public CampaignViewModel CampaignVM { get; set; }
		public DynamicFormulaViewModel DynamicFormulaVM { get; set; }
	}
}
