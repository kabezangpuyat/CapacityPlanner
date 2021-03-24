using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model.Web
{
    public class NavigationView
    {
        public List<ModuleViewModel> Parent { get; set; }
        public List <ModuleViewModel> Children { get; set; }
    }
}
