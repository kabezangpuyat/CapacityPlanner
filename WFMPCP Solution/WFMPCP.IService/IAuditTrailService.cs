using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IAuditTrailService
    {
        IQueryable<AuditTrailViewModel> GetAll();
        AuditTrailViewModel GetByID( int id );
        AuditTrailViewModel Create( AuditTrailViewModel model );
    }
}
