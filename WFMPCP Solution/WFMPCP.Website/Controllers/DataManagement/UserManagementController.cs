using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.DataManagement
{
    [Authorize]
    public class UserManagementController : Controller
    {
        #region Local Variable(s)
        private ApplicationUserManager _userManager;
        public ApplicationUserManager UserManager
        {
            get
            {
                return _userManager ?? HttpContext.GetOwinContext().GetUserManager<ApplicationUserManager>();
            }
            private set
            {
                _userManager = value;
            }
        }

        private IUserService _userService;
        private IUserRoleService _userRoleService;
        private IRoleService _roleService;
        #endregion

        #region Constructor(s)
        public UserManagementController()
        {

        }
        public UserManagementController( IUserService userService, IUserRoleService userRoleService, IRoleService roleService)
        {
            this._userService = userService;
            this._userRoleService = userRoleService;
            this._roleService = roleService;
        }
        #endregion

        // GET: UserManagement
        #region Action Result View
        public ActionResult ManageUser()
        {
            ViewBag.User = User.Identity.GetUserName();
			
			#region Setup UserLevel,User,Role to session
			if (Session["UserList"] == null)
				Session["UserList"] = this.Users;

			if(Session["UserLevels"] == null)
				Session["UserLevels"] = this.UserLevels.OrderBy(x => x).ToList();

			if(Session["RoleList"]==null)
				Session["RoleList"]= _roleService.GetAll().Where(x => x.Active == true).ToList();

			IQueryable<UserResult> users = (IQueryable<UserResult>)Session["UserList"];
			List<string> userLevels = (List<string>)Session["UserLevels"];
			List<RoleViewModel> roles = (List<RoleViewModel>)Session["RoleList"];
			#endregion

			ManagerUserView model = new ManagerUserView();
            model.UserLevels = userLevels;
            model.UsersVM = users;
            model.RoleVM = _roleService.GetAll().Where( x => x.Active == true ).ToList();

            return View(model);
        }

        [HttpPost]
        public ActionResult GetAllUsers(string userLevel)
        {
            string msg = string.Empty;

			if (Session["UserList"] == null)
				Session["UserList"] = this.Users;

			var users = (IQueryable<UserResult>)Session["UserList"];

            if( userLevel != "0" )
                users = users.Where( x => x.UserLevel == userLevel ).OrderBy( x => x.FullName ).AsQueryable();

            ManagerUserView model = new ManagerUserView();
            model.Message = msg;
            model.UsersVM = users;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult LoadDetails(int id)
        {
            ManagerUserView model = new ManagerUserView();
			//get user in session 
			if (Session["UserList"] == null)
				Session["UserList"] = this.Users;
			
			var user = ((IQueryable<UserResult>)Session["UserList"]).Where(x => x.ID == id).FirstOrDefault();
				//_userService.GetUser( id: id );
            if(user != null)
                if(user.ID > 0 )
                {
                    model.EmployeeID = user.EmployeeID;
                    var userRole = _userRoleService.GetByEmployeeID( user.EmployeeID );
                    if( userRole != null )
                        if( userRole.ID > 0 )
                        {
                            model.Active = userRole.Active == true ? "1" : "0";
                            model.RoleID = userRole.RoleID;
                        }
                }

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult Save( UserRoleSaveView data )
        {
            string username = User.Identity.GetUserName();
            ManagerUserView model = new ManagerUserView();

            UserRoleViewModel userRole = new UserRoleViewModel()
            {
                ID = data.ID,
                RoleID = data.RoleID,
                NTLogin = "",
                EmployeeID = data.EmployeeID,
                CreatedBy = username,
                DateCreated = DateTime.Now,
                DateModified = null,
                Active = data.Status
            };

            if(data.IsAdd)
            {
                var user = _userRoleService.Create( userRole );
                if( user != null )
                    if( user.ID > 0 )
                        model.Message = "Data added.";
            }
            else
            {
                if( data.IsDeactivate == false )
                {
                    userRole.ModifiedBy = username;
                    userRole.DateModified = DateTime.Now;
                    _userRoleService.Update( userRole, false );
                    model.Message = "Data updated.";
                }
                if( data.IsDeactivate == true)
                {
                    _userRoleService.Deactivate( userRole.EmployeeID );
                    model.Message = "Data deleted.";
                }
            }

            //_userRoleService.Create( data );
            //if( data.ID > 0 )
            //    model.Message = "New user added.";
             
            return Json( model, JsonRequestBehavior.AllowGet );
        }
        #endregion

        #region Method(s)
        private IQueryable<UserResult> Users
        {
            get
            {
                string[] userlevels = ConfigurationManager.AppSettings["EmployeeProfile.UserLevel"].Split( ',' ).ToArray();
				//_userService = new  userserver
				var users = _userService.GetAllUser().Where(x => userlevels.Contains(x.UserLevel)).OrderBy(x => x.FullName).AsQueryable();

				return users;
            }
        }

        private string[] UserLevels
        {
            get
            {
                string[] userlevels = ConfigurationManager.AppSettings["EmployeeProfile.UserLevel"].Split( ',' ).ToArray();

                return userlevels;
            }
        }
        #endregion

        #region JQGRID
        #region GridView
        private void SearchGrid(string searchOper, string searchField, string searchString,
            IQueryable<UserResult> gridData, ref IQueryable<UserResult> filteredData )
        {
            switch( searchOper )
            {
                case "eq":
                    if( searchField.Trim().ToLower() == "fullname" )
                    { filteredData = gridData.Where( x => x.FullName.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "employeeid" )
                    { filteredData = gridData.Where( x => x.EmployeeID.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "userlevel" )
                    { filteredData = gridData.Where( x => x.UserLevel.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "field1" )
                    { filteredData = gridData.Where( x => x.Field1.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "rolename" )
                    { filteredData = gridData.Where( x => x.RoleName.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    
                    break;
                case "cn":
                    if( searchField.Trim().ToLower() == "fullname" )
                    { filteredData = gridData.Where( s => s.FullName.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "employeeid" )
                    { filteredData = gridData.Where( s => s.EmployeeID.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "userlevel" )
                    { filteredData = gridData.Where( s => s.UserLevel.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "field1" )
                    { filteredData = gridData.Where( s => s.Field1.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "rolename" )
                    { filteredData = gridData.Where( s => s.RoleName.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    
                    break;
            }
        }
        [HttpPost]
        public ActionResult LoadjqData( string sidx, string sord, int page, int rows,
                bool _search, string searchField, string searchOper, string searchString )
        {
            // Get the list of users
            string[] employeeIds = _userRoleService.GetAll().Where( x => x.Active == true ).Select( x => x.EmployeeID ).ToArray();

            string[] userLevels = ConfigurationManager.AppSettings["EmployeeProfile.UserLevel"]
                                .Split( ',' ).Select( x => x.Trim() ).ToArray();

			#region Setup Grid data session
			if (Session["GridData"] == null)
			{
				Session["GridData"] = _userService.GetAllUser()
									.Where(x => employeeIds.Contains(x.EmployeeID.Trim()))
									.Select(x => new UserResult()
									{
										ID = x.ID,
										EmployeeID = x.EmployeeID,
										FullName = x.FullName,
										UserLevel = x.UserLevel,
										Field1 = _userRoleService.GetByEmployeeID(x.EmployeeID).Active == true ? "Active" : "Inactive",
										RoleName = _userRoleService.GetByEmployeeID(x.EmployeeID).RoleVM.Name
									})
									.AsQueryable();
			}
			#endregion


			IQueryable<UserResult> gridData = (IQueryable<UserResult>)Session["GridData"];

			// If search, filter the list against the search condition.
			// Only "contains" search is implemented here.
			var filteredData = gridData;
            if( _search )
            {
                this.SearchGrid( searchOper, searchField, searchString, gridData, ref filteredData );
            }
            // Sort the student list
            var sortedRoles = SortIQueryable<UserResult>( filteredData, sidx, sord ).AsEnumerable();

            // Calculate the total number of pages
            var totalRecords = filteredData.Count();
            var totalPages = (int)Math.Ceiling( (double)totalRecords / (double)rows );

            // NOTE:XXXX Prepare the data to fit the requirement of jQGrid
            var data =
                sortedRoles.Select( s => new
                {
                    id = s.ID,
                    cell = new object[] {
                        s.ID,
                        s.FullName,
                        s.EmployeeID,
                        s.UserLevel,
                        s.Field1 = _userRoleService.GetByEmployeeID( s.EmployeeID ).Active == true ? "Active" : "Inactive",
                        s.RoleName = _userRoleService.GetByEmployeeID(s.EmployeeID).RoleVM.Name
                    }
                } ).ToArray();

            // Send the data to the jQGrid
            var jsonData = new
            {
                total = totalPages,
                page = page,
                records = totalRecords,
                rows = data.Skip( ( page - 1 ) * rows ).Take( rows )
            };

            return Json( jsonData, JsonRequestBehavior.AllowGet );
        }
        [HttpPost]
        public ActionResult LoadjqData_Orig( string sidx, string sord, int page, int rows,
                bool _search, string searchField, string searchOper, string searchString )
        {
            // Get the list of users
            string[] employeeIds = _userRoleService.GetAll().Where( x => x.Active == true ).Select( x => x.EmployeeID ).ToArray();

            string[] userLevels = ConfigurationManager.AppSettings["EmployeeProfile.UserLevel"]
                                .Split( ',' ).Select( x => x.Trim() ).ToArray();
            IQueryable<UserResult> gridData = _userService.GetAllUser()
                .Where( x => employeeIds.Contains( x.EmployeeID.Trim() ) ).AsQueryable();
            
            // If search, filter the list against the search condition.
            // Only "contains" search is implemented here.
            var filteredData = gridData;
            if( _search )
            {
                switch( searchOper )
                {
                    case "eq":
                        filteredData = gridData.Where( x => x.FullName == searchString ).AsQueryable();
                        break;
                        //case "cn":
                        //    filteredRoles = category.Where( s => s.Name.Contains( searchString ) ).AsQueryable();
                        //    break;
                }

            }
            // Sort the student list
            var sortedRoles = SortIQueryable<UserResult>( filteredData, sidx, sord ).AsEnumerable();

            // Calculate the total number of pages
            var totalRecords = filteredData.Count();
            var totalPages = (int)Math.Ceiling( (double)totalRecords / (double)rows );

            // NOTE:XXXX Prepare the data to fit the requirement of jQGrid
            var data =
                sortedRoles.Select( s => new
                {
                    id = s.ID,
                    cell = new object[] {
                        s.ID,
                        s.FullName,
                        s.EmployeeID,
                        s.UserLevel
                    }
                } ).ToArray();

            // Send the data to the jQGrid
            var jsonData = new
            {
                total = totalPages,
                page = page,
                records = totalRecords,
                rows = data.Skip( ( page - 1 ) * rows ).Take( rows )
            };

            return Json( jsonData, JsonRequestBehavior.AllowGet );
        }
        #endregion
        #region SORT QUERY
        // Utility method to sort IQueryable given a field name as "string"
        // May consider to put in a cental place to be shared
        private IQueryable<T> SortIQueryable<T>( IQueryable<T> data, string fieldName, string sortOrder )
        {
            if( string.IsNullOrWhiteSpace( fieldName ) )
                return data;
            if( string.IsNullOrWhiteSpace( sortOrder ) )
                return data;

            var param = Expression.Parameter( typeof( T ), "i" );
            Expression conversion = Expression.Property( param, fieldName.Split( ',' ).Select( x => x ).FirstOrDefault() );
            var mySortExpression = Expression.Lambda<Func<T, object>>( conversion, param );

            return ( sortOrder == "desc" ) ? data.OrderByDescending( mySortExpression )
                : data.OrderBy( mySortExpression );
        }
        #endregion
        #endregion
    }
}
