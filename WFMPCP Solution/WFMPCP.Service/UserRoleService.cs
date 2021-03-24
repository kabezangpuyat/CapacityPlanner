using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class UserRoleService : IUserRoleService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public UserRoleService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<UserRoleViewModel> GetAll()
		{
			var data = _context.AsQueryable<UserRole>()
				.Select(x => new UserRoleViewModel()
				{
					ID = x.ID,
					RoleID = x.RoleID,
					NTLogin = x.NTLogin,
					EmployeeID = x.EmployeeID,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,

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
					}

					#endregion RoleVM
				});

			return data;
		}

		public List<UserRoleViewModel> GetAllByRoleID(int roleID)
		{
			return this.GetAll()
				.Where(x => x.RoleID == roleID)
				.ToList();
		}

		public UserRoleViewModel GetByID(int id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public UserRoleViewModel GetByEmployeeID(string employeeID, bool active = true)
		{
			return this.GetAll().Where(x => x.EmployeeID == employeeID && x.Active == active).FirstOrDefault();
		}

		public UserRoleViewModel GetByNTLogin(string ntlogin, bool active = true)
		{
			return this.GetAll().Where(x => x.NTLogin == ntlogin && x.Active == active).FirstOrDefault();
		}

		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<UserRole>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<UserRole>(data);
			_context.SaveChanges();
		}

		public void Deactivate(string employeeID)
		{
			_context.ExecuteTSQL(string.Format("UPDATE UserRole SET Active=0 WHERE EmployeeID='{0}'", employeeID));
		}

		public void Update(UserRoleViewModel model, bool isLogin = true)
		{
			var data = _context.AsQueryable<UserRole>()
						.Where(x => ((x.ID == model.ID) || (model.ID == null))
						   && ((x.EmployeeID == model.EmployeeID) || (model.EmployeeID == null))
						   && ((x.Active == model.Active) || (model.Active == null))
							)
						.FirstOrDefault();
			if (!isLogin)
			{
				data = _context.AsQueryable<UserRole>()
						.Where(x => ((x.EmployeeID == model.EmployeeID) || (model.EmployeeID == null))
						   && ((x.Active == model.Active) || (model.Active == null))
						 )
						.FirstOrDefault();
			}

			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.RoleID = model.RoleID ?? data.RoleID;
			data.NTLogin = model.NTLogin ?? data.NTLogin;
			data.EmployeeID = model.EmployeeID ?? data.EmployeeID;
			data.CreatedBy = model.CreatedBy ?? data.CreatedBy;
			data.ModifiedBy = model.ModifiedBy ?? data.ModifiedBy;
			data.DateModified = model.DateModified ?? data.DateModified;
			data.Active = model.Active ?? data.Active;

			_context.Update<UserRole>(data);
			_context.SaveChanges();
		}

		public UserRoleViewModel Create(UserRoleViewModel model)
		{
			//check if data exists
			var dataExists = _context.AsQueryable<UserRole>().Where(x => x.NTLogin == model.NTLogin && x.EmployeeID == model.EmployeeID && x.Active == true).FirstOrDefault();

			if (dataExists != null)
				this.Deactivate(dataExists.ID, model.ModifiedBy);

			//create data
			var data = new UserRole()
			{
				RoleID = (long)model.RoleID,
				NTLogin = model.NTLogin,
				EmployeeID = model.EmployeeID,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated,
				DateModified = null,
				Active = model.Active ?? true
			};

			_context.Add<UserRole>(data);
			_context.SaveChanges();

			model.ID = data.ID;

			return model;
		}

		#endregion Method(s)
	}
}