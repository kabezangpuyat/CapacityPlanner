using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class ModuleRolePermissionService : IModuleRolePermissionService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public ModuleRolePermissionService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<ModuleRolePermissionViewModel> GetAll()
		{
			var data = _context.AsQueryable<ModuleRolePermission>()
				.Select(x => new ModuleRolePermissionViewModel()
				{
					ID = x.ID,
					ModuleID = x.ModuleID,
					RoleID = x.RoleID,
					PermissionID = x.PermissionID,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,

					#region ModuleVM

					ModuleVM = new ModuleViewModel()
					{
						ID = x.Module.ID,
						ParentID = x.Module.ParentID,
						Name = x.Module.Name,
						Route = x.Module.Route,
						MenuIcon = x.Module.MenuIcon,
						FontAwesome = x.Module.FontAwesome,
						SortOrder = x.Module.SortOrder,
						CreatedBy = x.Module.CreatedBy,
						ModifiedBy = x.Module.ModifiedBy,
						DateCreated = x.Module.DateCreated,
						DateModified = x.Module.DateModified,
						Active = x.Module.Active
					},

					#endregion ModuleVM

					#region RoleVM

					RoleVM = new RoleViewModel()
					{
						ID = x.Role.ID,
						Name = x.Role.Name,
						Code = x.Role.Code,
						Description = x.Role.Description,
						CreatedBy = x.Role.CreatedBy,
						ModifiedBy = x.Role.ModifiedBy,
						DateCreated = x.Role.DateCreated,
						DateModified = x.Role.DateModified,
						Active = x.Role.Active
					},

					#endregion RoleVM

					#region PermissionVM

					PermissionVM = new PermissionViewModel()
					{
						ID = x.Permission.ID,
						Name = x.Permission.Name,
						Description = x.Permission.Description,
						CreatedBy = x.Permission.CreatedBy,
						ModifiedBy = x.Permission.ModifiedBy,
						DateCreated = x.Permission.DateCreated,
						DateModified = x.Permission.DateModified,
						Active = x.Permission.Active
					}

					#endregion PermissionVM
				}).AsQueryable();
			return data;
		}

		public List<ModuleRolePermissionViewModel> Get(int? moduleID = null, int? roleID = null, int? permissioonID = null, bool active = true)
		{
			var data = this.GetAll()
						.Where(x => x.Active == active
									&& ((x.ModuleID == (int)moduleID) || (moduleID == null))
									&& ((x.RoleID == (int)roleID) || (roleID == null))
									&& ((x.PermissionID == (int)permissioonID) || (permissioonID == null)))
						.ToList();

			return data;
		}

		public ModuleRolePermissionViewModel GetByID(int id, bool active = true)
		{
			return this.GetAll().Where(x => x.ID == id && x.Active == active).FirstOrDefault();
		}

		public void Deactivate(int id, string ntLogin)
		{
			var data = _context.AsQueryable<ModuleRolePermission>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.ModifiedBy = ntLogin;
			data.DateModified = DateTime.Now;

			_context.Update<ModuleRolePermission>(data);
			_context.SaveChanges();
		}

		public void Update(ModuleRolePermissionViewModel model)
		{
			var data = _context.AsQueryable<ModuleRolePermission>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.ModuleID = model.ModuleID;
			data.RoleID = model.RoleID;
			data.PermissionID = model.PermissionID;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active;

			_context.Update<ModuleRolePermission>(data);
			_context.SaveChanges();
		}

		public ModuleRolePermissionViewModel Create(ModuleRolePermissionViewModel model)
		{
			var dataExists = _context.AsQueryable<ModuleRolePermission>().Where(x => x.ModuleID == model.ModuleID && x.RoleID == model.RoleID && x.PermissionID == model.PermissionID && x.Active == true).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Permission mapping already exists.");

			var data = new ModuleRolePermission()
			{
				ModuleID = model.ModuleID,
				RoleID = model.RoleID,
				PermissionID = model.PermissionID,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active
			};

			_context.Add<ModuleRolePermission>(data);
			_context.SaveChanges();

			model.ID = data.ID;

			return model;
		}

		#endregion Method(s)
	}
}