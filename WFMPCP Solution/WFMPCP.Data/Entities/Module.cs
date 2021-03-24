using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class Module
    {
        public long ID { get; set; }
        public long ParentID { get; set; }
        public string Name { get; set; }
        public string Route { get; set; }
		public string MenuIcon { get; set; }
		public string FontAwesome { get; set; }
        public int SortOrder { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateModified { get; set; }
        public bool Active { get; set; }

        public virtual ICollection<ModuleRolePermission> ModuleRoleFunctions { get; set; }

    }
}
