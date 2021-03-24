using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.IService
{
	public interface IDynamicFormulaService
	{
		IQueryable<DynamicFormulaViewModel> GetAll();
		DynamicFormulaViewModel Get(long? id, string name, bool active);
		IQueryable<DynamicFormulaView> GetAllWebView();
		void Save(ref SiteCampaignLobFormulaViewModel model);
	}
}
