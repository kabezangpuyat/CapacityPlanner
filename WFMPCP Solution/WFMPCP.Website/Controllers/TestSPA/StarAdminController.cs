using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WFMPCP.Website.Controllers.TestSPA
{
    public class StarAdminController : Controller
    {
        // GET: StarAdmin
        public ActionResult Index()
        {
            return View();
        }
		public ActionResult AnotherPage()
		{
			return View();
		}
    }
}