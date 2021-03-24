using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
	public class DynamicFormulaViewModel
	{
		public long ID { get; set; }
		public string Name { get; set; }
		public string Description { get; set; }
		public DateTime DateCreated { get; set; }
		public DateTime? DateModified { get; set; }
		public bool Active { get; set; }

		public List<SiteCampaignLobFormulaViewModel> SiteCampaignLoBFormulasVM { get; set; }
	}
}
