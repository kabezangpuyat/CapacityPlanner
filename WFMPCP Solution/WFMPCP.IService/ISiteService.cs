using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ISiteService
    {
        IQueryable<SiteViewModel> GetAll();
        SiteViewModel GetByID( long id );
        void Deactivate( long id, string ntLogin );
        void Update( SiteViewModel model );
        SiteViewModel Create( SiteViewModel model );
    }
}
