using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class CampaignService : ICampaignService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public CampaignService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<CampaignViewModel> GetAll()
		{
			var data = _context.AsQueryable<Campaign>()
				.Select(x => new CampaignViewModel()
				{
					ID = x.ID,
					SiteID = x.SiteID,
					Name = x.Name,
					Code = x.Code,
					Description = x.Description,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,

					#region SiteVM

					//SiteVM = x.SiteID == 0 ? new SiteViewModel() : new SiteViewModel()
					//{
					//    ID = x.Site.ID,
					//    Name = x.Site.Name,
					//    Code = x.Site.Code,
					//    Description = x.Site.Description,
					//    CreatedBy = x.Site.CreatedBy,
					//    ModifiedBy = x.Site.ModifiedBy,
					//    DateCreated = x.Site.DateCreated,
					//    DateModified = x.Site.DateModified,
					//    Active = x.Site.Active
					//}

					#endregion SiteVM
				})
				.AsQueryable();

			return data;
		}

		public List<CampaignViewModel> GetAllBySiteID(long siteID, bool? active)
		{
			return this.GetAll().Where(x => x.SiteID == siteID
									   && ((x.Active == active) || (active == null))).ToList();
		}

		public CampaignViewModel GetByID(long id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		/// <summary>
		/// This is not a physical delete.
		/// </summary>
		/// <param name="id"></param>
		/// /// <param name="ntLogin">User's NTLogin</param>
		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<Campaign>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Campaign>(data);
			_context.SaveChanges();
		}

		public void Update(CampaignViewModel model)
		{
			var data = _context.AsQueryable<Campaign>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if campaign already exists
			if (data.Name != model.Name)
			{
				var dataExists = _context.AsQueryable<Campaign>().Where(x => x.Name == model.Name && x.Active == true).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("Campaign name already exists in site.");
			}

			data.SiteID = model.SiteID;
			data.Name = model.Name ?? data.Name;
			data.Code = model.Code ?? data.Code;
			data.Description = model.Description ?? data.Description;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active;

			_context.Update<Campaign>(data);
			_context.SaveChanges();
		}

		public CampaignViewModel Create(CampaignViewModel model)
		{
			var dataExists = _context.AsQueryable<Campaign>().Where(x => x.Name == model.Name && x.Active == true).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Campaign name already exists.");

			var data = new Campaign()
			{
				SiteID = model.SiteID,
				Name = model.Name,
				Code = model.Code,
				Description = model.Description,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active
			};

			_context.Add<Campaign>(data);
			_context.SaveChanges();

			model.ID = data.ID;

			return model;
		}

		#endregion Method(s)
	}
}