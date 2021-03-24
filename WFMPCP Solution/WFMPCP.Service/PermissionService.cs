using System;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class PermissionService : IPermissionService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public PermissionService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<PermissionViewModel> GetAll()
		{
			var data = _context.AsQueryable<Permission>()
				.Select(x => new PermissionViewModel()
				{
					ID = x.ID,
					Name = x.Name,
					Description = x.Description,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active
				}).AsQueryable();
			return data;
		}

		public PermissionViewModel GetByID(int id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(int id, string ntLogin)
		{
			var data = _context.AsQueryable<Permission>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Permission>(data);
			_context.SaveChanges();
		}

		public void Update(PermissionViewModel model)
		{
			var data = _context.AsQueryable<Permission>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if permission already exists
			if (data.Name != model.Name)
			{
				var dataExists = _context.AsQueryable<Permission>().Where(x => x.Name == model.Name).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("Permission name already exists.");
			}

			data.Name = model.Name ?? data.Name;
			data.Description = model.Description ?? data.Description;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active;

			_context.Update<Permission>(data);
			_context.SaveChanges();
		}

		public PermissionViewModel Create(PermissionViewModel model)
		{
			var dataExists = _context.AsQueryable<Permission>().Where(x => x.Name == model.Name).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Permission name already exists in site.");

			var data = new Permission()
			{
				Name = model.Name,
				Description = model.Description,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active
			};

			_context.Add<Permission>(data);
			_context.SaveChanges();

			model.ID = data.ID;

			return model;
		}

		#endregion Method(s)
	}
}