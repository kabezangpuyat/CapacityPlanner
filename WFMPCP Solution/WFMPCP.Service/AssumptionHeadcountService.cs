using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using WFMPCP.ICore;
using WFMPCP.IService;

namespace WFMPCP.Service
{
    public class AssumptionHeadcountService : IAssumptionHeadcountService
    {
        private readonly IWFMPCPContext _context;

        #region Constructor(s)
        public AssumptionHeadcountService(IWFMPCPContext context )
        {
            this._context = context;
        }
        #endregion

        #region IAssumptionHeadcountService
        public IEnumerable<Model.SegmentCategory> GetAllSegmentCategories()
        {
            var segmentCats = _context.AsQueryable<Model.SegmentCategory>()
                .Select( x => new Model.SegmentCategory() {
                    ID = x.ID,
                    Name = x.Name,
                    SortOrder =  x.SortOrder,
                    Visible = x.Visible,
                    Active = x.Active,
                    #region Segments
                    Segments = x.Segments.OrderBy(s=>s.SortOrder).Select(s=>new Model.Segment() {
                        ID = s.ID,
                        Name = s.Name,
                        SortOrder = s.SortOrder,
                        Visible = s.Visible,
                        Active = s.Active,
                        SegmentCategoryID = s.ID,
                        #region Datapoints
                        Datapoints = s.Datapoints.OrderBy(d=>d.SortOrder).Select(d=> new Model.Datapoint()
                        {
                            ID = d.ID,
                            Name = d.Name,
                            //ReferenceID = d.ReferenceID,
                            SortOrder = d.SortOrder,
                            Visible = d.Visible,
                            Active = d.Active,
                            Datatype =  d.Datatype
                        } )                       
                        #endregion
                    } )
                    #endregion
                } );

            return segmentCats;
        }

        public IEnumerable<Model.Segment> GetAllSegments()
        {
            var segments = _context.AsQueryable<Data.Entities.Segment>()
                            //.OrderBy(x=>x.SortOrder)
                            .Select( s => new Model.Segment()
                            {
                                ID = s.ID,
                                Name = s.Name,
                                SegmentCategoryID = (long)s.SegmentCategoryID,
                                SortOrder = s.SortOrder,
                                Visible = s.Visible,
                                Active = s.Active,
                                #region Datapoints
                                Datapoints = s.Datapoints.OrderBy( d => d.SortOrder ).Select( d => new Model.Datapoint()
                                {
                                    ID = d.ID,
                                    Name = d.Name,
                                    //ReferenceID = d.ReferenceID,
                                    SortOrder = d.SortOrder,
                                    Visible = d.Visible,
                                    Active = d.Active,
                                    Datatype = d.Datatype
                                } )
                                #endregion
                            } );           
            return segments;
        }
        public List<Dictionary<string, object>> Read( long? lobID, string start = "", string end = "", int includeDatapoint = 0,
            string tablename = "WeeklyAHDatapoint", string segmentCategoryID = "", string segmentID = "",
            string siteID = "", string campaignID = "" )
        {
            string lobid = "";
            if( lobID > 0 )
                lobid = lobID.ToString();

            if( tablename == "WeeklyStaffDatapoint" )
            {
                string procName = "wfmpcp_GetStaffPlanner_sp";
                string[] parameters = { "lobid", "start", "end", "includeDatapoint", "segmentid", "siteID", "campaignID" };
                object[] inputParams = { lobid, start, end, includeDatapoint, segmentID, siteID, campaignID  };
                return _context.Read( procName, parameters, inputParams );
            }
            else if( tablename == "WeeklyHiringDatapoint" )
            {
                string procName = "wfmpcp_GetHiringRequirements_sp";
                string[] parameters = { "campaignID", "start", "end", "includeDatapoint", "siteID" };
                object[] inputParams = { campaignID, start, end, includeDatapoint, siteID };
                return _context.Read( procName, parameters, inputParams );
            }
            else if(tablename== "WeeklyHiringDatapointTotal" )
            {
                string procName = "wfmpcp_GetHiringRequirementsTotal_sp";
                string[] parameters = { "campaignID", "start", "end", "includeDatapoint", "siteID" };
                object[] inputParams = { campaignID, start, end, includeDatapoint, siteID };
                return _context.Read( procName, parameters, inputParams );
            }
            else if (tablename== "WeeklySummaryDatapoint" )
            {
                string procName = "wfmpcp_GetSummary1_sp";
                string[] parameters = { "campaignID", "start", "end", "includeDatapoint", "siteID", "lobid" };
                object[] inputParams = { campaignID, start, end, includeDatapoint, siteID, lobid };
                return _context.Read( procName, parameters, inputParams );
            }
            else
            {
                string procName = "wfmpcp_GetAssumptionsHeadcount_sp";
                string[] parameters = { "lobid", "start", "end", "includeDatapoint", "tablename", "segmentcategoryid", "segmentid","siteID","campaignID" };
                object[] inputParams = { lobid, start, end, includeDatapoint, tablename, segmentCategoryID, segmentID, siteID, campaignID };
                return _context.Read( procName, parameters, inputParams );
            }
        }

        public void Save( Model.Web.AHCModel model )
        {
            string query = string.Format( "exec wfmpcp_SaveWeeklyAHDatapoint_sp {0},{1},{2},'{3}','{4}','{5}','{6}'", model.CampaignID,
                                                                                                       model.LobID,
                                                                                                       model.DatapointID,
                                                                                                       model.Data,
                                                                                                       model.Date,
                                                                                                       model.ModifiedBy,
                                                                                                       model.DateModified );
            //if( model.IsUpdate == false )
            //    query = "";//TODO: Insert Query Here
            _context.ExecuteTSQL( query );
        }

        public void Save(DataTable dt)
        {
            var parameter = new SqlParameter( "@WeeklyDatapointTableType", SqlDbType.Structured );
            parameter.Value = dt;
            parameter.TypeName = "[dbo].[WeeklyDatapointTableType]";

            //string query = string.Format( "exec wfmpcp_SaveWeeklyAHDatapointDatatable_sp {0}", parameter );
            _context.ExecuteTSQL( "exec wfmpcp_SaveWeeklyAHDatapointDatatable_sp @WeeklyDatapointTableType", parameter );
        }
        //public List<Dictionary<string, object>> Read( DbDataReader reader )
        //{
        //    List<Dictionary<string, object>> expandolist = new List<Dictionary<string, object>>();
        //    using( reader )
        //    {
        //        foreach( var item in reader )
        //        {
        //            IDictionary<string, object> expando = new ExpandoObject();
        //            foreach( PropertyDescriptor propertyDescriptor in TypeDescriptor.GetProperties( item ) )
        //            {
        //                var obj = propertyDescriptor.GetValue( item );
        //                expando.Add( propertyDescriptor.Name, obj );
        //            }
        //            expandolist.Add( new Dictionary<string, object>( expando ) );
        //        }
        //    }
        //    //reader.Close();
        //    return expandolist;
        //}

        //public DbDataReader GetPivotData( long? lobID, string start = "", string end = "", int includeDatapoint = 0 )
        //{
        //    string procName = "wfmpcp_GetAssumptionsHeadcount_sp";
        //    string[] parameters = { "lobid", "start", "end", "includeDatapoint" };
        //    object[] inputParams = { lobID, start, end, includeDatapoint };
        //    return _context.ExecuteDataReader( procName, parameters, inputParams );
        //}
        #endregion
    }
}
