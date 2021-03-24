using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;

namespace WFMPCP.Core
{
	public class Datasource
	{
		public static string WFMDatasource
		{
			get
			{
				string con = string.Empty;

				con = ConfigurationManager.ConnectionStrings["WFMPCP.Connection"].ConnectionString;

				return con;
			}
		}
		public static string EPMSDatasource
		{
			get
			{
				string con = string.Empty;

				con = ConfigurationManager.ConnectionStrings["EPMS.Connection"].ConnectionString;

				return con;
			}
		}
	}
}
