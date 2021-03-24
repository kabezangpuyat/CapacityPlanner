using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IUserRoleService
    {
        IQueryable<UserRoleViewModel> GetAll();
        List<UserRoleViewModel> GetAllByRoleID( int roleID );
        UserRoleViewModel GetByID( int id );
        UserRoleViewModel GetByEmployeeID( string employeeID, bool active = true );
        UserRoleViewModel GetByNTLogin( string ntlogin, bool active = true );
        void Deactivate( long id, string ntLogin );
        void Deactivate( string employeeID );
        void Update( UserRoleViewModel model, bool isLogin = true );
        UserRoleViewModel Create( UserRoleViewModel model );
    }
}
