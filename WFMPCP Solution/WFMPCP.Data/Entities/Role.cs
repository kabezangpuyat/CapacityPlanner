using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class Role
    {
        public long ID { get; set; }

        public string Name { get; set; }

        public string Code { get; set; }

        public string Description { get; set; }

        public string CreatedBy { get; set; }

        public string ModifiedBy { get; set; }

        public DateTime DateCreated { get; set; }

        public DateTime? DateModified { get; set; }

        public bool Active { get; set; }

        public virtual ICollection<ModuleRolePermission> ModuleRoleFunctions { get; set; }

        public virtual ICollection<UserRole> UserRoles { get; set; }
    }
}
