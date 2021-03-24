using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IRoleService
    {
        IQueryable<RoleViewModel> GetAll();
        RoleViewModel GetByID( int id );
        void Deactivate( int id, string ntLogin );
        void Update( RoleViewModel model );
        RoleViewModel Create( RoleViewModel model );
    }
}
