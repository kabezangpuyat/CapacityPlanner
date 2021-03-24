using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IActiveDirectoryService
    {
		ActiveDirectoryUser Authenticate( string ntLogin, string password );

        DirectoryEntry CreateDirectoryEntry( string username, string password );
    }
}
