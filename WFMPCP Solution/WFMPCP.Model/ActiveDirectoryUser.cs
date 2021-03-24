using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
	public class ActiveDirectoryUser
	{
		public string EmployeeNumber { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public byte[] ThumbnailPhoto { get; set; }
	}
}
