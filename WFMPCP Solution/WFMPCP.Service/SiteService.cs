using System;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class SiteService : ISiteService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public SiteService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<SiteViewModel> GetAll()
		{
			var data = _context.AsQueryable<Site>()
				.Select(x => new SiteViewModel()
				{
					ID = x.ID,
					Name = x.Name,
					Code = x.Code,
					Description = x.Description,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active
				}).AsQueryable();

			return data;
		}

		public SiteViewModel GetByID(long id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<Site>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Site>(data);
			_context.SaveChanges();
		}

		public void Update(SiteViewModel model)
		{
			var data = _context.AsQueryable<Site>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if lob already exists
			if (data.Name != model.Name)
			{
				var dataExists = _context.AsQueryable<Site>().Where(x => x.Name == model.Name).FirstOrDefault();
				if (dataExists != null)
					if (data.ID != dataExists.ID)
						throw new ArgumentException("Site name already exists.");
			}

			data.Name = model.Name ?? data.Name;
			data.Code = model.Code ?? data.Code;
			data.Description = model.Description ?? data.Description;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active;

			_context.Update<Site>(data);
			_context.SaveChanges();
		}

		public SiteViewModel Create(SiteViewModel model)
		{
			var dataExists = _context.AsQueryable<Site>().Where(x => x.Name == model.Name && x.Active == true).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Site name already exists in campaign.");

			var data = new Site()
			{
				Name = model.Name,
				Code = model.Code,
				Description = model.Description,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active
			};

			_context.Add<Site>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			return model;
		}

		#endregion Method(s)
	}
}