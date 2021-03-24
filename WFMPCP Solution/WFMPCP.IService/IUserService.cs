using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IUserService
    {
        UserResult GetUser( int? id = null, string employeeID = null );
        List<UserResult> GetAllBySite( string site );
        List<UserResult> GetAllUser();
        List<string> GetUserLevel();
        List<UserDetailSuperiorResult> GetAllUserDetailBySuperior( string superiorID );
        List<UserDetailResult> GetAllUserDetail();
        UserDetailResult GetUserDetail( int? id = null, string employeeID = null );
        List<string> GetAllUserSite();
    }
}
