using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    public class HiringDatapointViewModel
    {
        public long ID { get; set; }
        public long? SegmentID { get; set; }
        public long ReferenceID { get; set; }
        public string Name { get; set; }
        public string Datatype { get; set; }
        public int? SortOrder { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime? DateCreated { get; set; }
        public DateTime? DateModified { get; set; }
        public bool? Active { get; set; }
        public bool? Visible { get; set; }

        //public StaffSegmentViewModel StaffSegmentVM { get; set; }
    }
}
