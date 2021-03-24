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
    public class LoBManagementController : Controller
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

        private ILoBService _lobService;
        private ICampaignService _campaignService;
        private ISiteService _siteService;
        private ISiteCampaignService _siteCampaignService;
        private ISiteCampaignLoBService _siteCampaignLobService;
        #endregion

        #region Constructor(s)
        public LoBManagementController()
        {

        }
        public LoBManagementController( ICampaignService campaignService, ISiteService siteService, ILoBService lobService,
            ISiteCampaignService siteCampaignService , ISiteCampaignLoBService siteCampaignLobService )
        {
            this._campaignService = campaignService;
            this._siteService = siteService;
            this._lobService = lobService;
            this._siteCampaignService = siteCampaignService;
            this._siteCampaignLobService = siteCampaignLobService;
        }
        #endregion

        #region Action Result View
        public ActionResult ManageLoB()
        {
            ViewBag.User = User.Identity.GetUserName();
            //IQueryable<SiteViewModel> sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsQueryable();
            List<SiteCampaignView> sc = _siteCampaignService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.SiteVM.Name ).ThenBy( x => x.CampaignVM.Name )
                            .Select( x => new SiteCampaignView()
                            {
                                ID = x.ID,
                                Name = x.SiteVM.Name + "-" + x.CampaignVM.Name
                            } ).ToList();

            return View(Tuple.Create(sc));
        }

        [HttpPost]
        public ActionResult LoadDetails( long id )
        {
            var model = _lobService.GetByID( id );
            //_campaignService.GetByID( id );

            string siteCampaignIDs = string.Empty;

            var siteCampaigns = _siteCampaignService.GetAllSiteCampaignByLobID( id, true );
            if( siteCampaigns != null )
                foreach( var siteCampaign in siteCampaigns )
                {
                    siteCampaignIDs += string.Format( "{0},", siteCampaign.ID );
                }

            if( !string.IsNullOrEmpty( siteCampaignIDs ) )
                siteCampaignIDs = siteCampaignIDs.TrimEnd( ',' );

            model.SiteCampaignIds = siteCampaignIDs;
            //var sitecampaignLobs = _siteca

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult LoadCampaignBySite(long siteID )
        {
            var model = _campaignService.GetAllBySiteID( siteID, true );
            return Json( model, JsonRequestBehavior.AllowGet );
        }

        private LoBViewModel Create( LoBViewModel data, SiteCampaignViewModel siteCampaign )
        {
            _lobService.Create( data );

            if( data.ID > 0 )
            {
                //create SiteCampaignLOB
                _siteCampaignLobService.Create( new SiteCampaignLoBViewModel()
                {
                    SiteID = siteCampaign.SiteID,
                    CampaignID = siteCampaign.CampaignID,
                    LobID = data.ID,
                    Active = true
                } );
            }

            return data;
        }

        [HttpPost]
        public ActionResult Save( LoBViewModel data )
        {
            string username = User.Identity.GetUserName();
            CommonView model = new CommonView();
            string message = string.Empty;
            long lobID = 0;
            try
            {
                #region Update/Create data
                if( data.ID > 0 )
                {
                    //update
                    data.DateModified = DateTime.Now;
                    data.ModifiedBy = username;
                    _lobService.Update( data );
                    lobID = data.ID;
                    _siteCampaignLobService.Deactivate( lobID );
                }
                else
                {
                    //create LOB
                    data.DateCreated = DateTime.Now;
                    data.CreatedBy = username;
                    var lob = _lobService.Create( data );

                    lobID = data.ID;
                    _siteCampaignLobService.Deactivate( lobID );
                }

                #endregion

                foreach( var siteCampaignID in data.SiteCampaignIds.TrimEnd( ',' ).Split( ',' ) )
                {
                    long id = Convert.ToInt64( siteCampaignID );
                    //check if lobname exists
                    var siteCampaign = _siteCampaignService.Get( id, true );

                    long siteid = 0;
                    long campaignid = 0;
                    //long lobid = lobID;

                    #region Create/Update
                    if( siteCampaign != null )
                    {
                        var siteCampaignLob = _siteCampaignLobService.GetAll().Where( x => x.SiteID == siteCampaign.SiteID &&
                                     x.CampaignID == siteCampaign.CampaignID && x.LobID == lobID )
                                    .FirstOrDefault();

                        if( siteCampaignLob != null )
                        {
                            //update
                            siteCampaignLob.Active = true;

                            _siteCampaignLobService.Update( siteCampaignLob );
                        }
                        else
                        {
                            //create SiteCampaignLOB
                            _siteCampaignLobService.Create( new SiteCampaignLoBViewModel()
                            {
                                SiteID = siteCampaign.SiteID,
                                CampaignID = siteCampaign.CampaignID,
                                LobID = lobID,
                                Active = true
                            } );
                        }
                        siteid = siteCampaign.SiteID;
                        campaignid = siteCampaign.CampaignID;
                                                
                        message = "Lob Saved.";
                    }
                    #endregion

                    //Check if site campaign lob  have weeklyahdatapoin,weeklystaffdatapoint,weeklyhiringdatapoin
                    //      create those data.
                    if( siteid > 0 && campaignid > 0 && lobID > 0 )
                        _lobService.CreateWeeklyDatapoints( siteid, campaignid, lobID );
                }

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
        public ActionResult Save_09252017( LoBViewModel data )
        {
            string username = User.Identity.GetUserName();
            CommonView model = new CommonView();
            string message = string.Empty;
            try
            {
                foreach( var siteCampaignID in data.SiteCampaignIds.TrimEnd( ',' ).Split( ',' ) )
                {
                    long id = Convert.ToInt64( siteCampaignID );
                    //check if lobname exists
                    var siteCampaign = _siteCampaignService.Get( id, true );

                    long siteid = 0;
                    long campaignid = 0;
                    long lobid = 0;

                    #region Create/Update
                    if( siteCampaign != null )
                    {
                        var count = _siteCampaignLobService.Count( null,
                                                                siteCampaign.CampaignID,
                                                                data.Name,
                                                                true );


                        #region 
                        siteid = siteCampaign.SiteID;
                        campaignid = siteCampaign.CampaignID;
                        if( count == 0 )
                        {
                            //create LOB
                            data.DateCreated = DateTime.Now;
                            data.CreatedBy = username;
                            var lob = this.Create( data, siteCampaign );
                            lobid = lob.ID;
                        }
                        else if( count > 0 )
                        {
                            //exists
                            data.DateModified = DateTime.Now;
                            data.ModifiedBy = username;

                            //get lob
                            var lob = _siteCampaignLobService.GetAll().Where( x => x.CampaignID == siteCampaign.CampaignID && x.LobVM.Name == data.Name )
                                .Select( x => x.LobVM ).FirstOrDefault();
                            //_lobService.GetAll().Where( x => x.Name == data.Name && x.Active == true ).FirstOrDefault();
                            //check sitecampaignlob
                            count =
                                _siteCampaignLobService.GetAll().Where( x => x.CampaignID == siteCampaign.CampaignID
                                     && x.LobID == lob.ID
                                     && x.Active == true && x.LobVM.Active == true ).Count();

                            lobid = lob.ID;
                            if( count > 0 )
                            {
                                //update
                                _lobService.Update( data );
                                //create sitecampaignlob
                                _siteCampaignLobService.Create( lob.ID, siteCampaign.SiteID, siteCampaign.CampaignID );
                            }
                            else if( count == 0 )
                            {
                                //create lob and sitecampaignlob
                                this.Create( data, siteCampaign );
                            }
                        }


                        #endregion
                        message = "Lob Saved.";
                    }
                    #endregion

                    //Check if site campaign lob  have weeklyahdatapoin,weeklystaffdatapoint,weeklyhiringdatapoin
                    //      create those data.
                    if( siteid > 0 && campaignid > 0 && lobid > 0 )
                        _lobService.CreateWeeklyDatapoints( siteid, campaignid, lobid );
                }

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
                _lobService.Deactivate( id, username );
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
        private IQueryable<LoBViewModel> Lobs
        {
            get
            {
                return _lobService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsQueryable();
            }
        }

        #endregion

        #region JQGRID
        #region GridView
        [HttpPost]
        public ActionResult LoadjqData( string sidx, string sord, int page, int rows,
                bool _search, string searchField, string searchOper, string searchString )
        {
            IQueryable<LoBViewModel> gridData = this.Lobs;

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
                    case "cn":
                        filteredData = gridData.Where( s => s.Name.Contains( searchString ) ).AsQueryable();
                        break;
                }

            }
            // Sort the student list
            IEnumerable<LoBViewModel> sortedRoles = null;

            #region New Condition
            //if( sidx == "CampaignVM.Name" )
            //{
            //    sortedRoles = ( sord == "desc" ) ? filteredData.OrderByDescending( x => x.CampaignVM.Name ).AsQueryable()
            //        : filteredData.OrderBy( x => x.CampaignVM.Name ).AsEnumerable();
            //}
            //else if(sidx== "CampaignVM.SiteVM.Name" )
            //{
            //    sortedRoles = ( sord == "desc" ) ? filteredData.OrderByDescending( x => x.CampaignVM.SiteVM.Name ).AsQueryable()
            //      : filteredData.OrderBy( x => x.CampaignVM.SiteVM.Name ).AsEnumerable();
            //}
            //else
                sortedRoles = SortIQueryable<LoBViewModel>( filteredData, sidx, sord ).AsEnumerable();
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
                        s.Description
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