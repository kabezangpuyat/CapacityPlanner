using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class ModuleService : IModuleService
	{
		private readonly IWFMPCPContext _context;
		private ModuleRolePermissionService _moduleRolePermissionService;

		#region Constructor(s)

		public ModuleService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<ModuleViewModel> GetAll()
		{
			var data = _context.AsQueryable<Module>()
				.Select(x => new ModuleViewModel()
				{
					ID = x.ID,
					ParentID = x.ParentID,
					Name = x.Name,
					Route = x.Route,
					MenuIcon = x.MenuIcon,
					FontAwesome = x.FontAwesome,
					SortOrder = x.SortOrder,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active
				}).AsQueryable();
			return data;

			//List<ModuleViewModel> modules = null;
			//foreach(var module in _context.AsQueryable<Module>().Where(x=>x.ParentID==0) )
			//{
			//    ModuleViewModel model = new ModuleViewModel();
			//    model.ID = module.ID;
			//    model.ParentID = module.ParentID;
			//    model.Name = module.Name;
			//    model.Route = module.Route;
			//    model.SortOrder = module.SortOrder;
			//    model.CreatedBy = module.CreatedBy;
			//    model.ModifiedBy = module.ModifiedBy;
			//    model.DateCreated = module.DateCreated;
			//    model.DateModified = module.DateModified;
			//    model.Active = module.Active;
			//    //model.Children = new List<ModuleViewModel> ();//this.CreateChildren( module.ID );

			//    modules.Add( model );
			//}
			//return modules.AsQueryable();
		}

		public List<ModuleViewModel> GetAllByParentID(int parentID)
		{
			return this.GetAll().Where(x => x.ParentID == parentID).ToList();
		}

		public List<ModuleViewModel> GetAllByRoleID(long roleID)
		{
			_moduleRolePermissionService = new ModuleRolePermissionService(this._context);
			return _moduleRolePermissionService.GetAll()
								.Where(x => x.RoleID == roleID && x.Active == true)
								.Select(x => x.ModuleVM)
								.Distinct()
								.ToList();
		}

		public void Deactivate(int id, string ntLogin)
		{
			var data = _context.AsQueryable<Module>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.ModifiedBy = ntLogin;
			data.DateModified = DateTime.Now;

			_context.Update<Module>(data);
			_context.SaveChanges();
		}

		public void Update(ModuleViewModel model)
		{
			var data = _context.AsQueryable<Module>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if module already exists
			if (data.Name != model.Name || data.ParentID != model.ParentID)
			{
				var dataExists = _context.AsQueryable<Module>().Where(x => x.Name == model.Name && x.ParentID == model.ParentID).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("Module name already exists in site.");
			}

			data.ParentID = model.ParentID;
			data.Name = model.Name ?? data.Name;
			data.Route = model.Route ?? data.Route;
			data.SortOrder = model.SortOrder;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active;

			_context.Update<Module>(data);
			_context.SaveChanges();
		}

		public ModuleViewModel Create(ModuleViewModel model)
		{
			var dataExists = _context.AsQueryable<Module>().Where(x => x.Name == model.Name && x.ParentID == model.ParentID).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Module name already exists in it's parent.");

			var data = new Module()
			{
				ParentID = model.ParentID,
				Name = model.Name,
				Route = model.Route,
				SortOrder = model.SortOrder,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active
			};

			_context.Add<Module>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			return model;
		}

		#endregion Method(s)

		#region Private Method(s)

		private List<ModuleViewModel> CreateChildren(long parentID)
		{
			List<ModuleViewModel> modules = null;
			var data = _context.AsQueryable<Module>().Where(x => x.ParentID == parentID).ToList();
			if (data != null)
			{
				if (data.Count() > 0)
				{
					foreach (var module in data)
					{
						ModuleViewModel model = new ModuleViewModel();
						model.ID = module.ID;
						model.ParentID = module.ParentID;
						model.Name = module.Name;
						model.Route = module.Route;
						model.SortOrder = module.SortOrder;
						model.CreatedBy = module.CreatedBy;
						model.ModifiedBy = module.ModifiedBy;
						model.DateCreated = module.DateCreated;
						model.DateModified = module.DateModified;
						model.Active = module.Active;
						model.Children = this.CreateChildren(module.ParentID);

						modules.Add(model);
					}
				}
			}
			return modules;
		}

		#endregion Private Method(s)
	}
}