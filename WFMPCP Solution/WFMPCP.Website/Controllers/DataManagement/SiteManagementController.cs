using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.DataManagement
{
    [Authorize]
    public class SiteManagementController : Controller
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

        private ISiteService _siteService;
        #endregion

        #region Constructor(s)
        public SiteManagementController()
        {

        }
        public SiteManagementController( ISiteService siteService )
        {
            this._siteService = siteService;
        }
        #endregion

        #region Action Result View
        public ActionResult ManageSite()
        {
            ViewBag.User = User.Identity.GetUserName();
            
            return View();
        }      

        [HttpPost]
        public ActionResult LoadDetails( long id )
        {
            var model = _siteService.GetByID( id );

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult Save( SiteViewModel data )
        {
            string username = User.Identity.GetUserName();
            CommonView model = new CommonView();

            try
            {
                if( data.ID == 0 )
                {
                    SiteViewModel site = new SiteViewModel();
                    //add
                    data.CreatedBy = username;
                    data.DateCreated = DateTime.Now;

                    site = _siteService.Create( data );
                    if( site.ID > 0 )
                        model.Message = "Data added.";
                }
                else
                {
                    //update
                    data.DateModified = DateTime.Now;
                    data.ModifiedBy = username;

                    _siteService.Update( data );

                    model.Message = "Data updated.";
                }
            }
            catch (Exception ex)
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
                _siteService.Deactivate( id, username );
                model.Message = "Data deleted.";
            }
            catch(Exception ex)
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
        private IQueryable<SiteViewModel> Sites
        {
            get
            {
                return _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsQueryable();
            }
        }

        #endregion

        #region JQGRID
        #region GridView
        private void SearchGrid( string searchOper, string searchField, string searchString,
         IQueryable<SiteViewModel> gridData, ref IQueryable<SiteViewModel> filteredData )
        {
            switch( searchOper )
            {
                case "eq":
                    if( searchField.Trim().ToLower() == "name" )
                    { filteredData = gridData.Where( x => x.Name.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "code" )
                    { filteredData = gridData.Where( x => x.Code.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    break;
                case "cn":
                    if( searchField.Trim().ToLower() == "name" )
                    { filteredData = gridData.Where( s => s.Name.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "code" )
                    { filteredData = gridData.Where( s => s.Code.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    
                    break;
            }
        }
        [HttpPost]
        public ActionResult LoadjqData( string sidx, string sord, int page, int rows,
                bool _search, string searchField, string searchOper, string searchString )
        {
            IQueryable<SiteViewModel> gridData = this.Sites;

            // If search, filter the list against the search condition.
            // Only "contains" search is implemented here.
            var filteredData = gridData;
            if( _search )
            {
                this.SearchGrid( searchOper, searchField, searchString, gridData, ref filteredData );
            }
            // Sort the student list
            var sortedRoles = SortIQueryable<SiteViewModel>( filteredData, sidx, sord ).AsEnumerable();

            // Calculate the total number of pages
            var totalRecords = filteredData.Count();
            var totalPages = (int)Math.Ceiling( (double)totalRecords / (double)rows );

            // NOTE:XXXX Prepare the data to fit the requirement of jQGrid
            var data =
                sortedRoles.Select( s => new
                {
                    id = s.ID,
                    cell = new object[] {
                        s.ID,
                        s.Name,
                        s.Code
                    }
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