using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model.Web
{
	public class DynamicFormulaView
	{
		public long ID { get; set; }
		public long FormulaID { get; set; }
		public string FormulaName { get; set; }
		public string FormulaDescription { get; set; }
		public long SiteID { get; set; }
		public string SiteName { get; set; }
		public long CampaignID { get; set; }
		public string CampaignName { get; set; }
		public long LobID { get; set; }
		public string LobName { get; set; }
		public bool Active { get; set; }
	}
}
