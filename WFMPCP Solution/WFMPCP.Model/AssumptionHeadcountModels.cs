using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
    public class SegmentCategory
    {
        public int ID { get; set; }
        public string Name { get; set; }

        public int SortOrder { get; set; }
        public bool Active { get; set; }
        public bool Visible { get; set; }

       public IEnumerable<Segment> Segments { get; set; }

    }

    public class Segment
    {
        public long ID { get; set; }
        public long SegmentCategoryID { get; set; }
        public string Name { get; set; }
        public int SortOrder { get; set; }
        public bool Active { get; set; }
        public bool Visible { get; set; }

        public IEnumerable<Datapoint> Datapoints { get; set; }
    }

    public class Datapoint
    {
        public long ID { get; set; }
        //public long ReferenceID { get; set; }
        public string Name { get; set; }
        public string Datatype { get; set; }
        public int SortOrder { get; set; }
        public bool Active { get; set; }
        public bool Visible { get; set; }
    }
}
