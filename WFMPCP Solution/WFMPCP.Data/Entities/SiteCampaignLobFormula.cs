using System;
using System.Collections.Generic;	  
using System.Text;			   

namespace WFMPCP.Data.Entities
{
	public class SiteCampaignLobFormula
	{
		public long ID { get; set; }
		public long SiteID { get; set; }
		public long CampaignID { get; set; }
		public long LoBID { get; set; }
		public long DynamicFormulaID { get; set; }
		public DateTime DateCreated { get; set; }
		public DateTime? DateModified { get; set; }
		public bool Active { get; set; }

		#region Virtual
		public virtual Site Site { get; set; }
		public virtual Campaign Campaign { get; set; }
		public virtual LoB LoB { get; set; }
		public virtual DynamicFormula DynamicFormula { get; set; }
		#endregion
	}
}
