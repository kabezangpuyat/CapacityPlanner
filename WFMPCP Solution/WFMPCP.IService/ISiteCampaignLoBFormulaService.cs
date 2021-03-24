using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
	public interface ISiteCampaignLoBFormulaService
	{
		IQueryable<SiteCampaignLobFormulaViewModel> GetAll();
		SiteCampaignLobFormulaViewModel GetByID(long id);
		IQueryable<SiteCampaignLobFormulaViewModel> Get(long? siteID, long? campaignID, long? lobID, long? formulaID, bool active);

		SiteCampaignLobFormulaViewModel Create(SiteCampaignLobFormulaViewModel model);
		SiteCampaignLobFormulaViewModel Update(SiteCampaignLobFormulaViewModel model);

		void Deactivate(long id);
	}
}
