using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class ModuleRolePermissionViewModel
    {
        public long ID { get; set; }
        public long ModuleID { get; set; }
        public long RoleID { get; set; }
        public long PermissionID { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateModified { get; set; }
        public bool Active { get; set; }

        public ModuleViewModel ModuleVM { get; set; }
        public RoleViewModel RoleVM { get; set; }
        public  PermissionViewModel PermissionVM { get; set; }
    }
}
