using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class LoBService : ILoBService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public LoBService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<LoBViewModel> GetAll()
		{
			var data = _context.AsQueryable<LoB>()
				.Select(x => new LoBViewModel()
				{
					ID = x.ID,
					CampaignID = x.CampaignID,
					Name  = x.Name,
					Code = x.Code,
					Description = x.Description,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,

					#region CampaignVM

					//CampaignVM = x.CampaignID==0 ? new CampaignViewModel() : new CampaignViewModel()
					//{
					//    ID = x.Campaign.ID,
					//    SiteID = x.Campaign.SiteID,
					//    Name = x.Campaign.Name,
					//    Code = x.Campaign.Code,
					//    Description = x.Campaign.Description,
					//    CreatedBy = x.Campaign.CreatedBy,
					//    ModifiedBy = x.Campaign.ModifiedBy,
					//    DateCreated = x.Campaign.DateCreated,
					//    DateModified = x.Campaign.DateModified,
					//    Active = x.Campaign.Active,
					//    #region SiteVM
					//    SiteVM = new SiteViewModel()
					//    {
					//        ID = x.Campaign.Site.ID,
					//        Name = x.Campaign.Site.Name,
					//        Code = x.Campaign.Site.Code,
					//        Description = x.Campaign.Site.Description,
					//        CreatedBy = x.Campaign.Site.CreatedBy,
					//        ModifiedBy = x.Campaign.Site.ModifiedBy,
					//        DateCreated = x.Campaign.Site.DateCreated,
					//        DateModified = x.Campaign.Site.DateModified,
					//        Active = x.Campaign.Site.Active
					//    }
					//    #endregion
					//}

					#endregion CampaignVM
				}).AsQueryable();

			return data;
		}

		public List<LoBViewModel> GetAllByCampaignID(long campaignID, bool? active)
		{
			return this.GetAll().Where(x => x.CampaignID == campaignID
									   && ((x.Active==active) || (active == null))).ToList();
		}

		public LoBViewModel GetByID(long id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<LoB>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<LoB>(data);
			_context.SaveChanges();
		}

		public void Update(LoBViewModel model)
		{
			//get lob id from sitecampaign lob
			var data = _context.AsQueryable<LoB>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (string.IsNullOrEmpty(model.SiteCampaignIds.Trim()))
			{
				if (data == null)
					throw new ArgumentException("Data does not exists.");

				//check if lob already exists
				if (data.Name.Trim().ToLower() != model.Name.Trim().ToLower()
					|| data.CampaignID != model.CampaignID)
				{
					var dataExists = _context.AsQueryable<LoB>().Where(x => x.Name.Trim().ToLower() == model.Name.Trim().ToLower() && x.CampaignID == model.CampaignID).FirstOrDefault();
					if (dataExists != null)
						throw new ArgumentException("Lob name already exists in site.");
				}
			}
			data.CampaignID = model.CampaignID;
			data.Name = model.Name ?? data.Name;
			data.Code = model.Code ?? data.Code;
			data.Description = model.Description ?? data.Description;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active;

			_context.Update<LoB>(data);
			_context.SaveChanges();
		}

		public void CreateWeeklyDatapoints(long siteID, long campaignID, long lobID)
		{
			string query = string.Format("EXEC [dbo].[wfmpcp_CreateWeeklyDatapoints_sp] {0},{1},{2}", siteID, campaignID, lobID);
			_context.ExecuteTSQL(query);
		}

		public LoBViewModel Create(LoBViewModel model)
		{
			if (string.IsNullOrEmpty(model.SiteCampaignIds.Trim()))
			{
				var dataExists = _context.AsQueryable<LoB>().Where(x => x.Name == model.Name && x.CampaignID == model.CampaignID && x.Active == true).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("LoB name already exists in campaign.");
			}

			var data = new LoB()
			{
				CampaignID = model.CampaignID,
				Name = model.Name,
				Code = model.Code,
				Description = model.Description,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active
			};

			_context.Add<LoB>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			return model;
		}

		#endregion Method(s)
	}
}