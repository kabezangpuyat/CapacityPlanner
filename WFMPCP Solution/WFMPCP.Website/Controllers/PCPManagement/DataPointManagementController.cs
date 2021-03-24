using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.PCPManagement
{
    [Authorize]
    public class DataPointManagementController : Controller
    {
        #region Local Variable(s)
        private ApplicationUserManager _userManager;
        public ApplicationUserManager UserManager
        {
            get
            {
                return _userManager ?? HttpContext.GetOwinContext().GetUserManager<ApplicationUserManager>();
            }
            private set
            {
                _userManager = value;
            }
        }

        private IDatapointService _datapointService;
        private ISegmentService _segmentService;
        #endregion

        #region Constructor(s)
        public DataPointManagementController()
        {

        }
        public DataPointManagementController( IDatapointService datapointService, ISegmentService segmentService )
        {
            this._datapointService = datapointService;
            this._segmentService = segmentService;
        }
        #endregion

        #region Action Result View
        public ActionResult ManageDatapoint()
        {
            ViewBag.User = User.Identity.GetUserName();
            IQueryable<SegmentViewModel> sites = _segmentService.GetAll().Where( x => x.Active == true && x.Visible == true ).OrderBy( x => x.SortOrder ).AsQueryable();
            return View( Tuple.Create( sites ) );
        }

        [HttpPost]
        public ActionResult LoadDetails( long id )
        {
            var model = _datapointService.GetByID( id );

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult Save( DatapointViewModel data )
        {
            string username = User.Identity.GetUserName();
            CommonView model = new CommonView();

            try
            {
                if( data.ID == 0 )
                {
                    DatapointViewModel segment = new DatapointViewModel();
                    //add
                    data.CreatedBy = username;
                    data.DateCreated = DateTime.Now;

                    segment = _datapointService.Create( data );
                    if( segment.ID > 0 )
                        model.Message = "Data added.";
                }
                else
                {
                    //update
                    data.DateModified = DateTime.Now;
                    data.ModifiedBy = username;

                    _datapointService.Update( data );

                    model.Message = "Data updated.";
                }
            }
            catch( Exception ex )
            {
                if( ex.GetType() == typeof( ArgumentException ) )
                    model.Message = ( (ArgumentException)ex ).Message;
                else
                    model.Message = "Unable to save data. Please contact your system administrator.";
            }


            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult Delete( long id )
        {
            string username = User.Identity.GetUserName();
            CommonView model = new CommonView();

            try
            {
                _datapointService.Deactivate( id, username );
                model.Message = "Data deleted.";
            }
            catch( Exception ex )
            {
                if( ex.GetType() == typeof( ArgumentException ) )
                    model.Message = ( (ArgumentException)ex ).Message;
                else
                    model.Message = "Unable to delete data. Please contact your system administrator.";
            }

            return Json( model, JsonRequestBehavior.AllowGet );
        }
        #endregion

        #region Method(s)
        private IQueryable<DatapointViewModel> Datapoints
        {
            get
            {
                return _datapointService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.SortOrder ).AsQueryable();
            }
        }

        #endregion

        #region JQGRID
        #region GridView
        [HttpPost]
        public ActionResult LoadjqData( string sidx, string sord, int page, int rows,
                bool _search, string searchField, string searchOper, string searchString )
        {
            IQueryable<DatapointViewModel> gridData = this.Datapoints;

            // If search, filter the list against the search condition.
            // Only "contains" search is implemented here.
            var filteredData = gridData;
            if( _search )
            {
                switch( searchOper )
                {
                    case "eq":
                        filteredData = gridData.Where( x => x.Name == searchString ).AsQueryable();
                        break;
                }

            }
            // Sort the student list
            IEnumerable<DatapointViewModel> sortedData = null;

            #region New Condition
            if( sidx == "SegmentVM.Name" )
                sortedData = ( sord == "desc" ) ? filteredData.OrderByDescending( x => x.SegmentVM.Name ).AsQueryable()
                    : filteredData.OrderBy( x => x.SegmentVM.Name ).AsEnumerable();
            else
                sortedData = SortIQueryable<DatapointViewModel>( filteredData, sidx, sord ).AsEnumerable();
            #endregion

            // Calculate the total number of pages
            var totalRecords = filteredData.Count();
            var totalPages = (int)Math.Ceiling( (double)totalRecords / (double)rows );

            // NOTE:XXXX Prepare the data to fit the requirement of jQGrid
            var data =
                sortedData.Select( s => new
                {
                    id = s.ID,
                    cell = new object[] {
                        s.ID,
                        s.Name,
                        s.SegmentVM.Name
                    },
                } ).ToArray();

            // Send the data to the jQGrid
            var jsonData = new
            {
                total = totalPages,
                page = page,
                records = totalRecords,
                rows = data.Skip( ( page - 1 ) * rows ).Take( rows )
            };
            return Json( jsonData, JsonRequestBehavior.AllowGet );

        }

        #endregion
        #region SORT QUERY
        // Utility method to sort IQueryable given a field name as "string"
        // May consider to put in a cental place to be shared
        private IQueryable<T> SortIQueryable<T>( IQueryable<T> data, string fieldName, string sortOrder )
        {
            if( string.IsNullOrWhiteSpace( fieldName ) )
                return data;
            if( string.IsNullOrWhiteSpace( sortOrder ) )
                return data;

            var param = Expression.Parameter( typeof( T ), "i" );
            Expression conversion = Expression.Property( param, fieldName.Split( ',' ).Select( x => x ).FirstOrDefault() );
            var mySortExpression = Expression.Lambda<Func<T, object>>( conversion, param );

            return ( sortOrder == "desc" ) ? data.OrderByDescending( mySortExpression )
                : data.OrderBy( mySortExpression );
        }
        #endregion
        #endregion
    }
}