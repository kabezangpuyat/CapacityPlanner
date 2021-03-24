using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class UserRole
    {
        public long ID { get; set; }
        public long RoleID { get; set; }
        public string NTLogin { get; set; }
        public string EmployeeID { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateModified { get; set; }
        public bool Active { get; set; }

        public virtual Role Role { get; set; }
    }
}
