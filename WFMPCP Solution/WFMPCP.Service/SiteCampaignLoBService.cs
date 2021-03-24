using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class SiteCampaignLoBService : ISiteCampaignLoBService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public SiteCampaignLoBService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region ISiteCampaignService

		public IQueryable<SiteCampaignLoBViewModel> GetAll()
		{
			var data = _context.AsQueryable<SiteCampaignLoB>()
				.Select(x => new SiteCampaignLoBViewModel()
				{
					ID = x.ID,
					SiteID = x.SiteID,
					CampaignID = x.CampaignID,
					LobID = x.LoBID,
					Active = x.Active,
					SiteVM = new SiteViewModel()
					{
						ID = x.SiteID,
						Name = x.Site.Name,
						Code = x.Site.Code,
						Description = x.Site.Description,
						CreatedBy = x.Site.CreatedBy,
						ModifiedBy = x.Site.ModifiedBy,
						DateCreated = x.Site.DateCreated,
						DateModified = x.Site.DateModified,
						Active = x.Site.Active
					},
					CampaignVM = new CampaignViewModel()
					{
						ID = x.CampaignID,
						Name = x.Campaign.Name,
						Code = x.Campaign.Code,
						Description = x.Campaign.Description,
						CreatedBy = x.Campaign.CreatedBy,
						ModifiedBy = x.Campaign.ModifiedBy,
						DateCreated = x.Campaign.DateCreated,
						DateModified = x.Campaign.DateModified,
						Active = x.Campaign.Active
					},
					LobVM = new LoBViewModel()
					{
						ID = x.LoBID,
						Name = x.LoB.Name,
						Code = x.LoB.Code,
						Description = x.LoB.Description,
						CreatedBy = x.LoB.CreatedBy,
						ModifiedBy = x.LoB.ModifiedBy,
						DateCreated = x.LoB.DateCreated,
						DateModified = x.LoB.DateModified,
						Active = x.LoB.Active
					}
				}).AsQueryable();

			return data;
		}

		public List<SiteCampaignLoBViewModel> GetAllLoBBySiteCampaign(long siteID, long campaignID, bool? active)
		{
			return this.GetAll()
				.Where(x => x.SiteID == siteID && x.CampaignID == campaignID
				   && ((x.Active == active) || (active == null))
					&& ((x.LobVM.Active == active) || (active == null))).ToList();
		}

		public SiteCampaignLoBViewModel Create(SiteCampaignLoBViewModel model)
		{
			try
			{
				SiteCampaignLoB data = new SiteCampaignLoB()
				{
					SiteID = model.SiteID,
					CampaignID = model.CampaignID,
					LoBID = model.LobID,
					Active = model.Active
				};
				_context.Add<SiteCampaignLoB>(data);
				_context.SaveChanges();

				model.ID = data.ID;

				return model;
			}
			catch (Exception ex)
			{
				throw new ArgumentException("Unexpected error encountered. Please contact yours system Adminsitrator.", ex.InnerException);
			}
		}

		public int Count(long? siteID, long campaignID, string lobName, bool? active)
		{
			int retValue = 0;

			retValue = this.GetAll()
				.Where(x => ((x.SiteID == siteID) || (siteID == null)) && x.CampaignID == campaignID && x.LobVM.Name == lobName
				   && ((x.Active == active) || (active == null))).Count();

			return retValue;
		}

		public int Count(long? siteID, long campaignID, long lobid, bool? active)
		{
			int retValue = 0;

			retValue = this.GetAll()
				.Where(x => ((x.SiteID == siteID) || (siteID == null)) && x.CampaignID == campaignID && x.LobID == lobid
				   && ((x.Active == active) || (active == null))).Count();

			return retValue;
		}

		public void Create(long lobID, long siteID, long campaignID)
		{
			try
			{
				//string deact = string.Format( "UPDATE SiteCampaignLoB SET Active=0 WHERE LoBID={0} AND SiteID={1} AND CampaignID={2}", lobID, siteID, campaignID );
				//_context.ExecuteTSQL( deact );

				//create new
				SiteCampaignLoB data = new SiteCampaignLoB()
				{
					SiteID = siteID,
					CampaignID = campaignID,
					LoBID = lobID,
					Active = true
				};
				_context.Add<SiteCampaignLoB>(data);
				_context.SaveChanges();
			}
			catch (Exception ex)
			{
				throw new ArgumentException("Unexpected error encountered. Please contact your system administrator.", ex.InnerException);
			}
		}

		public void Deactivate(long lobID)
		{
			string qry = string.Format("UPDATE SiteCampaignLoB SET Active=0 WHERE LoBID={0}", lobID);
			_context.ExecuteTSQL(qry);
		}

		public void Update(SiteCampaignLoBViewModel model)
		{
			try
			{
				if (model != null)
				{
					SiteCampaignLoB data = _context.AsQueryable<SiteCampaignLoB>().Where(x => x.ID == model.ID).FirstOrDefault();
					data.SiteID = model.SiteID;
					data.CampaignID = model.CampaignID;
					data.LoBID = model.LobID;
					data.Active = model.Active;

					_context.Update<SiteCampaignLoB>(data);
					_context.SaveChanges();
				}
			}
			catch (Exception ex)
			{
				throw new ArgumentException("Unexpected error encountered. Please contact your system administrator.", ex.InnerException);
			}
		}

		#endregion ISiteCampaignService
	}
}