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
	public class SiteCampaignService : ISiteCampaignService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public SiteCampaignService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region ISiteCampaignService

		public IQueryable<SiteCampaignViewModel> GetAll()
		{
			var data = _context.AsQueryable<SiteCampaign>()
				.Select(x => new SiteCampaignViewModel()
				{
					ID = x.ID,
					SiteID = x.SiteID,
					CampaignID = x.CampaignID,
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
					Active = x.Active
				}).AsQueryable();

			return data;
		}

		public List<SiteCampaignViewModel> GetAllSiteCampaignBySiteID(long siteID, bool? active)
		{
			return this.GetAll().Where(x => x.SiteID == siteID && ((x.Active == active) || (active == null))).ToList();
		}

		public List<SiteCampaignViewModel> GetAllSiteCampaignByCampaignID(long campaignID, bool? active)
		{
			return this.GetAll().Where(x => x.CampaignID == campaignID && ((x.Active == active) || (active == null))).ToList();
		}

		public SiteCampaignViewModel Get(long id, bool? active)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public List<SiteCampaignViewModel> GetAllSiteCampaignByLobID(long lobID, bool? active)
		{
			var query = string.Format(@"SELECT
                            sc.ID
                            , sc.SiteID
                            , sc.CampaignID
                            , sc.Active
                            FROM SiteCampaign sc
                            INNER JOIN SiteCampaignLoB scl ON scl.SiteID = sc.SiteID  AND scl.CampaignID = sc.CampaignID
                            WHERE scl.LobID = {0}
                            AND sc.Active = {1}
                            AND scl.Active=1", lobID, (active == true ? 1 : 0));

			var siteCampaign = _context.GetList<SiteCampaignViewModel>(query);

			return siteCampaign;
		}

		public void Create(long campaignID, string siteIDs)
		{
			try
			{
				string deact = string.Format("UPDATE SiteCampaign SET Active=0 WHERE CampaignID={0}", campaignID);
				_context.ExecuteTSQL(deact);

				//create new
				if (!string.IsNullOrEmpty(siteIDs))
					foreach (var siteid in siteIDs.TrimEnd(',').Split(',').ToArray())
					{
						SiteCampaign siteCampaign = new SiteCampaign()
						{
							SiteID = Convert.ToInt64(siteid),
							CampaignID = campaignID,
							Active = true
						};

						_context.Add<SiteCampaign>(siteCampaign);
						_context.SaveChanges();
					}
			}
			catch (Exception ex)
			{
				throw new ArgumentException("Unexpected error encountered. Please contact your system administrator.", ex.InnerException);
			}
		}

		public void Deactivate(long campaignID)
		{
			var siteCampaings = _context.AsQueryable<SiteCampaign>().Where(x => x.CampaignID == campaignID).ToList();
			foreach (var siteCampaign in siteCampaings)
			{
				siteCampaign.Active = false;
				_context.Update<SiteCampaign>(siteCampaign);
				_context.SaveChanges();
			}
		}

		public SiteCampaignViewModel Create(SiteCampaignViewModel model)
		{
			throw new NotImplementedException();
		}

		#endregion ISiteCampaignService
	}
}