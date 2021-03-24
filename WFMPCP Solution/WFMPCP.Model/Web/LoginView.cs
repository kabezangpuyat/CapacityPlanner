using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model.Web
{
    public class LoginView
    {
        public string NTLogin { get; set; }
        public string Password { get; set; }
        public string EmployeeID { get; set; }
        public string Message { get; set; }
        public long UserID { get; set; }
        public long RoleID { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string RoleName { get; set; }
    }
}
