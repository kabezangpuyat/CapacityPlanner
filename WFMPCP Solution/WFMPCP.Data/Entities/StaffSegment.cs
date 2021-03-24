using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class StaffSegment
    {
        public long ID { get; set; }
        public int? SegmentCategoryID { get; set; }
        public string Name { get; set; }
        public int SortOrder { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateModified { get; set; }
        public bool Active { get; set; }
        public bool  Visible { get; set; }

        //public virtual SegmentCategory SegmentCategory { get; set; }

        public virtual ICollection<StaffDatapoint> StaffDatapoints { get; set; }
    }
}
