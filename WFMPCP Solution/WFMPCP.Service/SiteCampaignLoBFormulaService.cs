using System;
using System.Linq;

using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class SiteCampaignLoBFormulaService : ISiteCampaignLoBFormulaService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public SiteCampaignLoBFormulaService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region ISiteCampaignLoBFormulaService

		public IQueryable<SiteCampaignLobFormulaViewModel> Get(long? siteID, long? campaignID, long? lobID,
			long? formulaID, bool active)
		{
			var data = this.GetAll().Where(x => ((x.SiteID == (long)siteID) || (siteID == null))
						&& ((x.CampaignID == (long)campaignID) || (campaignID == null)) && ((x.LoBID == (long)lobID) || (lobID == null))
						&& ((x.DynamicFormulaID == formulaID) || (formulaID == null)) && x.Active == active).AsQueryable();

			return data;
		}

		public IQueryable<SiteCampaignLobFormulaViewModel> GetAll()
		{
			var data = _context.AsQueryable<SiteCampaignLobFormula>()
				.Select(x => new SiteCampaignLobFormulaViewModel()
				{
					ID = x.ID,
					SiteID = x.SiteID,
					CampaignID = x.CampaignID,
					LoBID = x.LoBID,
					DynamicFormulaID = x.DynamicFormulaID,
					Active = x.Active,

					#region SiteVM

					SiteVM = new SiteViewModel()
					{
						ID = x.SiteID,
						Name = x.Site.Name,
						Code = x.Site.Code
					},

					#endregion SiteVM

					#region CampaignVM

					CampaignVM = new CampaignViewModel()
					{
						ID = x.CampaignID,
						Name = x.Campaign.Name,
						Code = x.Campaign.Code
					},

					#endregion CampaignVM

					#region LobVM

					LoBVM = new LoBViewModel()
					{
						ID = x.LoBID,
						Name = x.LoB.Name,
						Code = x.LoB.Code
					},

					#endregion LobVM

					#region DynamicVM

					DynamicFormulaVM = new DynamicFormulaViewModel()
					{
						ID = x.DynamicFormulaID,
						Name = x.DynamicFormula.Name
					}

					#endregion DynamicVM
				}).AsQueryable();

			return data;
		}

		public SiteCampaignLobFormulaViewModel GetByID(long id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public SiteCampaignLobFormulaViewModel Create(SiteCampaignLobFormulaViewModel model)
		{
			//check if exists
			var origData = this.Get(model.SiteID, model.CampaignID, model.LoBID, null, true);
			if (origData.Count() > 0)
				throw new ArgumentException("Insert failed. Mapping already exists.");

			var data = new SiteCampaignLobFormula()
			{
				SiteID = model.SiteID,
				CampaignID = model.CampaignID,
				LoBID = model.LoBID,
				DynamicFormulaID = model.DynamicFormulaID,
				DateCreated = DateTime.Now,
				DateModified = null,
				Active = true
			};

			_context.Add<SiteCampaignLobFormula>(data);
			_context.SaveChanges();

			model.ID = data.ID;

			return model;
		}

		public SiteCampaignLobFormulaViewModel Update(SiteCampaignLobFormulaViewModel model)
		{
			//check if exists

			#region Validate

			var data = _context.AsQueryable<SiteCampaignLobFormula>()
								.Where(x => x.ID == model.ID).FirstOrDefault();

			long origSiteID = 0;
			long origCampaignID = 0;
			long origLobID = 0;

			if (data != null)
				if (data.ID > 0)
				{
					origSiteID = data.SiteID;
					origCampaignID = data.CampaignID;
					origLobID = data.LoBID;
				}

			if (origSiteID != model.SiteID && origCampaignID != model.CampaignID && origLobID != model.LoBID)
			{
				var existingdata = this.Get(model.SiteID, model.CampaignID, model.LoBID, null, true);
				if (existingdata.Count() > 0)
					throw new ArgumentException("Update failed. Mapping already exists.");
			}

			#endregion Validate

			data.SiteID = model.SiteID;
			data.CampaignID = model.CampaignID;
			data.LoBID = model.LoBID;
			data.DynamicFormulaID = model.DynamicFormulaID;
			data.DateModified = DateTime.Now;

			_context.Update<SiteCampaignLobFormula>(data);
			_context.SaveChanges();

			return model;
		}

		public void Deactivate(long id)
		{
			var data = _context.AsQueryable<SiteCampaignLobFormula>().Where(x => x.ID == id).FirstOrDefault();
			data.Active = false;
			data.DateModified = DateTime.Now;

			_context.Update<SiteCampaignLobFormula>(data);
			_context.SaveChanges();
		}

		#endregion ISiteCampaignLoBFormulaService
	}
}