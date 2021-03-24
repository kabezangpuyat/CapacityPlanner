using System.Linq;

using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Service
{
	public class DynamicFormulaService : IDynamicFormulaService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public DynamicFormulaService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region IDynamicFormulaService

		public DynamicFormulaViewModel Get(long? id, string name, bool active)
		{
			var data = this.GetAll()
				.Where(x => ((x.ID == (int)id) || (id == null)) && ((x.Name == name || (name == null)) && x.Active == active)).FirstOrDefault();

			return data;
		}

		public IQueryable<DynamicFormulaViewModel> GetAll()
		{
			var data = _context.AsQueryable<DynamicFormula>()
				.Select(x => new DynamicFormulaViewModel()
				{
					ID = x.ID,
					Name = x.Name,
					Description = x.Description,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active
				}).AsQueryable();

			return data;
		}

		public IQueryable<DynamicFormulaView> GetAllWebView()
		{
			var data = _context.AsQueryable<SiteCampaignLobFormula>()
				.Select(x => new DynamicFormulaView()
				{
					ID = x.ID,
					SiteID = x.SiteID,
					CampaignID = x.CampaignID,
					LobID = x.LoBID,
					FormulaID = x.DynamicFormulaID,
					SiteName = x.Site.Name,
					CampaignName = x.Campaign.Name,
					LobName = x.LoB.Name,
					FormulaName = x.DynamicFormula.Name,
					FormulaDescription = x.DynamicFormula.Description,
					Active = x.Active
				}).AsQueryable();

			return data;
		}

		public void Save(ref SiteCampaignLobFormulaViewModel model)
		{
			var data = _context.Add<SiteCampaignLobFormula>(new SiteCampaignLobFormula()
			{
				SiteID = model.SiteID,
				CampaignID = model.CampaignID,
				LoBID = model.LoBID,
				DynamicFormulaID = model.DynamicFormulaID,
				DateCreated = model.DateCreated,
				Active = model.Active
			});
			_context.SaveChanges();
			model.ID = data.ID;
		}

		#endregion IDynamicFormulaService
	}
}