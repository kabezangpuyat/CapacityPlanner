using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WFMPCP.Model.Web
{
    public class ManagerUserView : CommonView
    {
        public List<UserRoleViewModel> UserRolesVM { get; set; }

        public IQueryable<UserResult> UsersVM { get; set; }

        public IQueryable<UserDetailResult> UserDetailsVM { get; set; }

        public List<RoleViewModel> RoleVM { get; set; }

        public List<string> UserLevels { get; set; }
        
        #region Displaying Selected user
        public string EmployeeID { get; set; }

        public string Active { get; set; } 

        public long? RoleID { get; set; }
        #endregion

    }

    public class UserRoleSaveView
    {
        public long ID { get; set; }
        public string EmployeeID { get; set; }

        public long? RoleID { get; set; }

        public bool IsAdd { get; set; }

        public bool IsDeactivate { get; set; }

        public bool Status { get; set; }
    }
}
