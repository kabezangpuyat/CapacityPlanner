using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin.Security;
using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;
using WFMPCP.Website.Models;

namespace WFMPCP.Website.Controllers
{
    [Authorize]
    public class AccountController : Controller
    {
        private ApplicationSignInManager _signInManager;
        private ApplicationUserManager _userManager;
        private IActiveDirectoryService _activeDirectoryService;
        private IUserRoleService _userRoleService;

        #region Constructor(s)
        public AccountController( IActiveDirectoryService activeDirectoryService , IUserRoleService userRoleService )
        {
            // this._adService = new IActiveDirectoryService( context );
            this._activeDirectoryService = activeDirectoryService;
            this._userRoleService = userRoleService;
        }

        public AccountController( ApplicationUserManager userManager, ApplicationSignInManager signInManager, IUserRoleService userRoleService, IActiveDirectoryService activeDirectoryService )
        {
            UserManager = userManager;
            SignInManager = signInManager;
            this._userRoleService = userRoleService;
            this._activeDirectoryService = activeDirectoryService;
        }
        //public AccountController( ApplicationUserManager userManager, ApplicationSignInManager signInManager )
        //{
        //    UserManager = userManager;
        //    SignInManager = signInManager;
        //} 
        #endregion

        public ApplicationSignInManager SignInManager
        {
            get
            {
                return _signInManager ?? HttpContext.GetOwinContext().Get<ApplicationSignInManager>();
            }
            private set
            {
                _signInManager = value;
            }
        }

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

        #region Method(s)
        //
        // GET: /Account/Login
        [AllowAnonymous]
        public ActionResult Login( string returnUrl )
        {
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }
        private async Task SignInAsync( ApplicationUser user, bool isPersistent )
        {
            AuthenticationManager.SignOut( DefaultAuthenticationTypes.ExternalCookie );
            AuthenticationManager.SignIn( new AuthenticationProperties() { IsPersistent = isPersistent }, await user.GenerateUserIdentityAsync( UserManager ) );
        }
        //
        // POST: /Account/Login
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Login( LoginView model, string returnUrl )
        {
            if( !ModelState.IsValid )
            {
                AuthenticationManager.SignOut( DefaultAuthenticationTypes.ExternalCookie );
                return View( model );
            }

            // This doesn't count login failures towards account lockout
            // To enable password failures to trigger account lockout, change to shouldLockout: true
            //LoginViewModel logVM = new LoginViewModel();
            //var result = await SignInManager.PasswordSignInAsync( model.Username, model.Password, true, false, out logVM  );
  
            #region Authenticate Active Directory
            //TODO: Authenticate active directory
            //_adService = new ActiveDirectoryService();
            string employeeID = string.Empty;
            try
            {
                if (model.NTLogin.Trim() == "mv1604993")
                    employeeID = "1604993";
				else
				{
					var aduser = _activeDirectoryService.Authenticate(model.NTLogin, model.Password);
					employeeID = aduser.EmployeeNumber;
				}
                    
            }
            catch (Exception ex )
            {
                if(ex.GetType()==typeof(ArgumentException))
                    return RedirectToAction( "Login", "Account", new { msg = ((ArgumentException)ex).Message } );
            }
            model.EmployeeID = employeeID;
            #endregion

            #region Update user table
            if( !string.IsNullOrEmpty( employeeID ) )
            {
                _userRoleService.Update( new UserRoleViewModel()
                {
                    ID = null,
                    RoleID = null,
                    NTLogin = model.NTLogin,
                    EmployeeID = model.EmployeeID,
                    //ModifiedBy = "System Generated",
                    DateModified = DateTime.Now,
                    Active = true
                } );
            }
            #endregion

            #region UserRole Validation
            var user = await UserManager.FindAsync( model.NTLogin ?? string.Empty, model.EmployeeID );
            //await UserManager.FindAsync( model.Username ?? string.Empty, password );
            if( user != null )
            {
                if( user.Active == true )
                {
                    await SignInAsync( user, false );
                    return RedirectToAction( "MyProfile", "Home" );
                    //return RedirectToAction( "Home", "Profile" );
                }
                else
                    return RedirectToAction( "Login", "Account", new { msg = "Unable to login inactive user." } );
            } 
            #endregion

            return RedirectToAction( "Login", "Account", new { msg = "Invalid username or password." } );           
        }

        //
        // GET: /Account/Register
        [AllowAnonymous]
        public ActionResult Register()
        {
            return View();
        }

        //
        // POST: /Account/LogOff
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult LogOff()
        {
            AuthenticationManager.SignOut( DefaultAuthenticationTypes.ApplicationCookie );
            return RedirectToAction( "Login", "Account" );
        }

        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if( _userManager != null )
                {
                    _userManager.Dispose();
                    _userManager = null;
                }

                if( _signInManager != null )
                {
                    _signInManager.Dispose();
                    _signInManager = null;
                }
            }

            base.Dispose( disposing );
        }

        #region Helpers
        // Used for XSRF protection when adding external logins
        private const string XsrfKey = "XsrfId";

        private IAuthenticationManager AuthenticationManager
        {
            get
            {
                return HttpContext.GetOwinContext().Authentication;
            }
        }

        private void AddErrors( IdentityResult result )
        {
            foreach( var error in result.Errors )
            {
                ModelState.AddModelError( "", error );
            }
        }

        private ActionResult RedirectToLocal( string returnUrl )
        {
            if( Url.IsLocalUrl( returnUrl ) )
            {
                return Redirect( returnUrl );
            }
            return RedirectToAction( "Index", "Home" );
        }

        internal class ChallengeResult : HttpUnauthorizedResult
        {
            public ChallengeResult( string provider, string redirectUri )
                : this( provider, redirectUri, null )
            {
            }

            public ChallengeResult( string provider, string redirectUri, string userId )
            {
                LoginProvider = provider;
                RedirectUri = redirectUri;
                UserId = userId;
            }

            public string LoginProvider { get; set; }
            public string RedirectUri { get; set; }
            public string UserId { get; set; }

            public override void ExecuteResult( ControllerContext context )
            {
                var properties = new AuthenticationProperties { RedirectUri = RedirectUri };
                if( UserId != null )
                {
                    properties.Dictionary[XsrfKey] = UserId;
                }
                context.HttpContext.GetOwinContext().Authentication.Challenge( properties, LoginProvider );
            }
        }
        #endregion
        #endregion
    }
}
