using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IModuleService
    {
        IQueryable<ModuleViewModel> GetAll();  
        List<ModuleViewModel> GetAllByParentID( int parentID );
        List<ModuleViewModel> GetAllByRoleID( long roleID );
        void Deactivate( int id, string ntLogin );
        void Update( ModuleViewModel model );
        ModuleViewModel Create( ModuleViewModel model );
    }
}
