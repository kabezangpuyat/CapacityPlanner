using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.IService
{
    public interface IAssumptionHeadcountService
    {
        IEnumerable<Model.SegmentCategory> GetAllSegmentCategories();

        IEnumerable<Model.Segment> GetAllSegments();
        List<Dictionary<string, object>> Read( long? lobID, string start = "", string end = "", int includeDatapoint = 0, string tablename = "WeeklyAHDatapoint", string segmentCategoryID = "", string segmentID = "", string siteID = "", string campaignID = "" );
        //DbDataReader GetPivotData( long? lobID, string start = "", string end = "", int includeDatapoint = 0 );
        void Save( Model.Web.AHCModel model );
        void Save( DataTable dt );
    }
}
