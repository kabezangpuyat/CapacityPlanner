using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model.Web
{
    public class AHCViews
    {
        public List<Dictionary<string, object>> Pivot { get; set; }

        public List<Dictionary<string, object>> PivotHiringTotal { get; set; }

        //public List<Dictionary<string, object>> AssumptionPivot { get; set; }
        //public List<Dictionary<string, object>> HeadCountPivot { get; set; }
        public List<WFMPCP.Model.Segment> Segments { get; set; }

        public IEnumerable<WFMPCP.Model.DatapointViewModel> Datapoints { get; set; }

        public List<WFMPCP.Model.StaffDatapointViewModel> StaffDatapoints { get; set; }

        public List<WFMPCP.Model.HiringDatapointViewModel> HiringDatapoints { get; set; }

        public List<WFMPCP.Model.SummaryDatapointViewModel> SummaryDatapoints { get; set; }

        public List<WFMPCP.Model.SiteCampaignLoBViewModel> SiteCampaignLobs { get; set; }

        public IEnumerable<Model.SiteViewModel> Sites { get; set; }
        public List<string> SegmentValues { get; set; }

        public string LobID { get; set; }
        public string SiteID { get; set; }
        public string CampaignID { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }

        public bool IsLoadDataGrid { get; set; }
    }

    public class AHCModel
    {
        public long? ID { get; set; }
        public string LobID { get; set; }
        public string SiteID { get; set; }
        public string CampaignID { get; set; }
        public string Date { get; set; }
        public long DatapointID { get; set; }

        public string Data { get; set; }

        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime? DateCreated { get; set; }

        public DateTime? DateModified { get; set; }
        public  bool IsUpdate { get; set; }
    }
}
