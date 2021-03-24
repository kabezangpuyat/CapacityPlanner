using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(WFMPCP.WebsiteV2.Startup))]
namespace WFMPCP.WebsiteV2
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
