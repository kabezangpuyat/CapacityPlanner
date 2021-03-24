using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;
using Microsoft.Owin.Security;
using WFMPCP.Website.Models;

namespace WFMPCP.Website
{
    public class EmailService : IIdentityMessageService
    {
        public Task SendAsync( IdentityMessage message )
        {
            // Plug in your email service here to send an email.
            return Task.FromResult( 0 );
        }
    }

    public class SmsService : IIdentityMessageService
    {
        public Task SendAsync( IdentityMessage message )
        {
            // Plug in your SMS service here to send a text message.
            return Task.FromResult( 0 );
        }
    }

    // Configure the application user manager which is used in this application.
    public class ApplicationUserManager : UserManager<ApplicationUser, long>
    {
        public ApplicationUserManager( IUserStore<ApplicationUser, long> store )
            : base( store ) { }

        public static ApplicationUserManager Create()
        {
            var manager = new ApplicationUserManager( new ApplicationUserStore() );
            return manager;
        }
    }

    // Configure the application sign-in manager which is used in this application.  
    public class ApplicationSignInManager : SignInManager<ApplicationUser, long>
    {
        public ApplicationSignInManager
            ( ApplicationUserManager userManager, IAuthenticationManager authenticationManager )
            : base( userManager, authenticationManager ) { }

        public static ApplicationSignInManager Create
            ( IdentityFactoryOptions<ApplicationSignInManager> options, IOwinContext context )
        {
            return new ApplicationSignInManager
                ( context.GetUserManager<ApplicationUserManager>(), context.Authentication );
        }
    }
}
