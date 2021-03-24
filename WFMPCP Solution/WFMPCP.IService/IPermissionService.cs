using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IPermissionService
    {
        IQueryable<PermissionViewModel> GetAll();
        PermissionViewModel GetByID( int id );
        void Deactivate( int id, string ntLogin );
        void Update( PermissionViewModel model );
        PermissionViewModel Create( PermissionViewModel model );
    }
}
