using System;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

using Ninject;
using Ninject.Modules;

using WFMPCP.Website.IoC;

namespace WFMPCP.Website
{
    public class MvcApplication : HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure( WebApiConfig.Register );
            FilterConfig.RegisterGlobalFilters( GlobalFilters.Filters );
            RouteConfig.RegisterRoutes( RouteTable.Routes );
            BundleConfig.RegisterBundles( BundleTable.Bundles );


            #region Ninject
            NinjectModule registration = new NinjectRegistration();
            var kernel = new StandardKernel( registration );
            var ninjectResolver = new NinjectDependencyResolver( kernel );

            DependencyResolver.SetResolver( ninjectResolver );
            GlobalConfiguration.Configuration.DependencyResolver = ninjectResolver;
            #endregion
        }

        protected void Application_Error( object sender, EventArgs e )
        {
            Exception exception = Server.GetLastError();
            Response.Clear();

            HttpException httpException = exception as HttpException;

            if( httpException != null )
            {
                string action = "Error";

                //switch( httpException.GetHttpCode() )
                //{
                //    case 404:
                //        // page not found
                //        action = "HttpError404";
                //        break;
                //    case 500:
                //        // server error
                //        action = "HttpError500";
                //        break;
                //    default:
                //        action = "General";
                //        break;
                //}

                // clear error on server
                //Server.ClearError();

                //Response.Redirect( String.Format( "~/Common/{0}/?message={1}", action, exception.Message ) );

                Response.Redirect( string.Format( "~/Common/{0}/", action ) );
            }
            else
                Response.Redirect( string.Format( "~/Common/Error/" ) );
        }
    }
}
