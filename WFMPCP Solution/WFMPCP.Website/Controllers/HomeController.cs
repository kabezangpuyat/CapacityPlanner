using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;

namespace WFMPCP.Website.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        #region Local Variable(s)
        private ApplicationUserManager _userManager;
        private IUserRoleService _userRoleService;

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
        #endregion

        #region Constructor(s)
        public HomeController()
        {

        }
        public HomeController( IUserRoleService userRoleService )
        {
            this._userRoleService = userRoleService;
        }

        //public HomeController( ApplicationUserManager userManager )
        //{
        //    _userManager = userManager;
        //    var user = UserManager.FindById( Convert.ToInt32( User.Identity.GetUserId() ) );
        //    if( user != null )
        //    {
        //        //TODO: Condition here if those roles are allowed or not
        //        //if( user.RoleID != Convert.ToInt32( AAC.Web.Model.Enum.UserRole.Pilot ) )
        //        //{
        //        //    RedirectToAction( "LogOff", "Account" );
        //        //}
        //    }
        //}
        #endregion

        #region Controller Action(s)

        public ActionResult Index()
        {
            var userId = Convert.ToInt32( User.Identity.GetUserId() );
        
            return View();
        } 

        public ActionResult MyProfile()
        {
            var userId = Convert.ToInt32( User.Identity.GetUserId() );
            ViewBag.User = User.Identity.GetUserName();
            var model = _userRoleService.GetByID( userId );
                     
            return View( model );
        }
        #endregion
    }
}
