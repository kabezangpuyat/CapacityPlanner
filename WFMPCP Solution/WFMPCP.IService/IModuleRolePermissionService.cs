using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IModuleRolePermissionService
    {
        IQueryable<ModuleRolePermissionViewModel> GetAll();
        List<ModuleRolePermissionViewModel> Get( int? moduleID = null, int? roleID = null, int? permissioonID = null, bool active = true );
        ModuleRolePermissionViewModel GetByID( int id, bool active = true );
        void Deactivate( int id, string ntLogin );
        void Update( ModuleRolePermissionViewModel model );
    }
}
