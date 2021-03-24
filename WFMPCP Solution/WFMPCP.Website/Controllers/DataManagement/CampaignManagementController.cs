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

namespace WFMPCP.Website.Controllers.DataManagement
{
    [Authorize]
    public class CampaignManagementController : Controller
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

        private ICampaignService _campaignService;
        private ISiteService _siteService;
        private ISiteCampaignService _siteCampaignService;
        #endregion

        #region Constructor(s)
        public CampaignManagementController()
        {

        }
        public CampaignManagementController( ICampaignService campaignService, ISiteService siteService, ISiteCampaignService siteCampaignService )
        {
            this._campaignService = campaignService;
            this._siteService = siteService;
            this._siteCampaignService = siteCampaignService;
        }
        #endregion

        #region Action Result View
        public ActionResult ManageCampaign()
        {
            ViewBag.User = User.Identity.GetUserName();
            IQueryable<SiteViewModel> sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsQueryable();
            return View(Tuple.Create(sites));
        }

        [HttpPost]
        public ActionResult LoadDetails( long id )
        {
            var model = _campaignService.GetByID( id );
            string siteIDs = string.Empty;

            var siteCampaigns = _siteCampaignService.GetAllSiteCampaignByCampaignID( id, true );
            if( siteCampaigns != null )
                foreach(var siteCampaign in siteCampaigns )
                {
                    siteIDs += string.Format( "{0},", siteCampaign.SiteID );
                }

            if( !string.IsNullOrEmpty( siteIDs ) )
                siteIDs = siteIDs.TrimEnd( ',' );

            model.SiteIDs = siteIDs;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult Save( CampaignViewModel data )
        {
            string username = User.Identity.GetUserName();
            CommonView model = new CommonView();
            string message = string.Empty;

            try
            {
                if( data.ID == 0 )
                {
                    CampaignViewModel campaign = new CampaignViewModel();
                    //add
                    data.CreatedBy = username;
                    data.DateCreated = DateTime.Now;
                    data.SiteID = 0;

                    campaign = _campaignService.Create( data );
                    if( campaign.ID > 0 )
                    {
                        message = "Data added.";
                        data.ID = campaign.ID;
                    }
                }
                else
                {
                    //update
                    data.DateModified = DateTime.Now;
                    data.ModifiedBy = username;
                    data.SiteID = 0;

                    _campaignService.Update( data );

                    message = "Data updated.";
                }

                _siteCampaignService.Create( data.ID, data.SiteIDs );

                model.Message = message;
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
                _campaignService.Deactivate( id, username );
                _siteCampaignService.Deactivate( id );
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
        private string CampaignSites( long campaignId )
        {
            string retValue = string.Empty;

            var sites = _siteCampaignService.GetAllSiteCampaignByCampaignID( campaignId, true ).ToList();
            if(sites != null)
                if(sites.Count() > 0)
                    foreach(var site in sites)
                    {
                        if( site.SiteVM != null )
                            retValue += string.Format( "{0},", site.SiteVM.Name );
                    }

            retValue = retValue.TrimEnd( ',' );
            return retValue;
        }
        private IQueryable<CampaignViewModel> Campaigns
        {
            get
            {
                var campaigns = _campaignService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).ToList();
                List<CampaignViewModel> returnValue = new List<CampaignViewModel>();
                foreach( var c in campaigns)
                {
                    returnValue.Add( new CampaignViewModel()
                    {
                        ID = c.ID,
                        Name = c.Name,
                        Code = c.Code,
                        Description = c.Description,
                        SiteName = this.CampaignSites( c.ID )
                    } );
                }
                return returnValue.OrderBy( x => x.Name ).AsQueryable();
            }
        }

        #endregion

        #region JQGRID
        #region GridView
        private void SearchGrid( string searchOper, string searchField, string searchString,
            IQueryable<CampaignViewModel> gridData, ref IQueryable<CampaignViewModel> filteredData )
        {
            switch( searchOper )
            {
                case "eq":
                    if( searchField.Trim().ToLower() == "name" )
                    { filteredData = gridData.Where( x => x.Name.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "code" )
                    { filteredData = gridData.Where( x => x.Code.ToLower() == searchString.ToLower() ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "sitename" )
                    { filteredData = gridData.Where( x => x.SiteName.ToLower() == searchString.ToLower() ).AsQueryable(); }

                    break;
                case "cn":
                    if( searchField.Trim().ToLower() == "name" )
                    { filteredData = gridData.Where( s => s.Name.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "code" )
                    { filteredData = gridData.Where( s => s.Code.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    if( searchField.Trim().ToLower() == "sitename" )
                    { filteredData = gridData.Where( s => s.SiteName.ToLower().Contains( searchString.ToLower() ) ).AsQueryable(); }
                    
                    break;
            }
        }
        [HttpPost]
        public ActionResult LoadjqData( string sidx, string sord, int page, int rows,
                bool _search, string searchField, string searchOper, string searchString )
        {
            IQueryable<CampaignViewModel> gridData = this.Campaigns;
            // If search, filter the list against the search condition.
            // Only "contains" search is implemented here.
            var filteredData = gridData;
            if( _search )
            {
                this.SearchGrid( searchOper, searchField, searchString, gridData, ref filteredData );
            }
            // Sort the student list
            IEnumerable<CampaignViewModel> sortedRoles = null;

            #region New Condition
            sortedRoles = SortIQueryable<CampaignViewModel>( filteredData, sidx, sord ).AsEnumerable();
            #endregion

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
                        s.Code,
                        s.SiteName
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