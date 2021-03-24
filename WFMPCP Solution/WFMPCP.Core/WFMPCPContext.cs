using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Dynamic;
using System.Linq;

using Dapper;
using WFMPCP.ICore;
using WFMPCP.Core.Mappings;

namespace WFMPCP.Core
{
	public class WFMPCPContext : DbContext, IWFMPCPContext
	{
		#region Constructor

		public WFMPCPContext() : base("name=WFMPCP.Connection")
		{
		}

		public WFMPCPContext(string connectionString)
			: base(connectionString)
		{
		}

		#endregion Constructor

		#region Method(s)

		protected override void OnModelCreating(DbModelBuilder modelBuilder)
		{
			modelBuilder.Configurations.Add(new CampaignMapping());
			modelBuilder.Configurations.Add(new PermissionMapping());
			modelBuilder.Configurations.Add(new LoBMapping());
			modelBuilder.Configurations.Add(new ModuleMapping());
			modelBuilder.Configurations.Add(new ModuleRolePermissionMapping());
			modelBuilder.Configurations.Add(new RoleMapping());
			modelBuilder.Configurations.Add(new SiteMapping());
			modelBuilder.Configurations.Add(new UserRoleMapping());
			modelBuilder.Configurations.Add(new AuditTrailMapping());
			modelBuilder.Configurations.Add(new SegmentCategoryMapping());
			modelBuilder.Configurations.Add(new SegmentMapping());
			modelBuilder.Configurations.Add(new DatapointMapping());
			modelBuilder.Configurations.Add(new WeeklyDatapointMapping());
			modelBuilder.Configurations.Add(new WeeklyDatapointLogMapping());
			modelBuilder.Configurations.Add(new StaffSegmentMapping());
			modelBuilder.Configurations.Add(new StaffDatapointMapping());
			modelBuilder.Configurations.Add(new WeeklyStaffDatapointMapping());
			modelBuilder.Configurations.Add(new HiringDatapointMapping());
			modelBuilder.Configurations.Add(new WeeklyHiringDatapointMapping());
			modelBuilder.Configurations.Add(new SiteCampaignMapping());
			modelBuilder.Configurations.Add(new SiteCampaignLoBMapping());
			modelBuilder.Configurations.Add(new SummaryDatapointMapping());
			modelBuilder.Configurations.Add(new WeeklySummaryDatapointMapping());
			modelBuilder.Configurations.Add(new StagingWeeklyDatapointMapping());
			modelBuilder.Configurations.Add(new DynamicFormulaMapping());
			modelBuilder.Configurations.Add(new SiteCampaignLobFormulaMapping());

			base.OnModelCreating(modelBuilder);
		}

		#endregion Method(s)

		#region IWFMPCPContext

		public IQueryable<T> AsQueryable<T>() where T : class
		{
			return this.Set<T>();
		}

		public T Add<T>(T item) where T : class
		{
			this.Set<T>().Add(item);
			return item;
		}

		public T Remove<T>(T item) where T : class
		{
			this.Set<T>().Remove(item);
			return item;
		}

		public T Update<T>(T item) where T : class
		{
			var entry = this.Entry(item);

			if (entry != null)
			{
				entry.CurrentValues.SetValues(item);
			}
			else
			{
				this.Attach(item);
			}

			return item;
		}

		public T Attach<T>(T item) where T : class
		{
			this.Set<T>().Attach(item);
			return item;
		}

		public T Detach<T>(T item) where T : class
		{
			this.Entry(item).State = EntityState.Detached;
			return item;
		}

		public override int SaveChanges()
		{
			return base.SaveChanges();
		}

		//public void ExecuteTSQL(string tsql)
		//{
		//	base.Database.ExecuteSqlCommand(tsql);
		//	base.SaveChanges();
		//}

		public void ExecuteTSQL(string tsql, SqlParameter parameter)
		{
			base.Database.ExecuteSqlCommand(tsql, parameter);
			base.SaveChanges();
		}

		#region SQLDataReader
		public SqlDataReader ExecuteDataReader(string cmdText, string[] paramList, object[] values, bool isSp = true)
		{
			string source = Datasource.WFMDatasource;
			SqlConnection conn = new SqlConnection(source);
			try
			{
				conn.Open();
				SqlCommand cmd = new SqlCommand(cmdText, conn);
				cmd.CommandType = isSp == true ? CommandType.StoredProcedure : CommandType.Text;

				// We want to convert our parameter list to an ADO
				// Parameter collection, so we will iterate through the list
				// if it is not null
				// Log information.
				if (paramList != null)
				{
					List<SqlParameter> parameters = Parameters(paramList, values);
					if (parameters != null)
						if (parameters.Count > 0)
							cmd.Parameters.AddRange(parameters.ToArray());
				}

				return cmd.ExecuteReader(CommandBehavior.CloseConnection);
			}
			catch (Exception ex)
			{
				throw ex;
			}

		}
		private List<SqlParameter> Parameters(string[] paramList, object[] values)
		{
			//string oParam = string.Empty;
			//return Parameters( paramList, values, out oParam );
			//return parameters;
			List<SqlParameter> parameters = new List<SqlParameter>();
			for (int i = 0; i < paramList.Length; i++)
			{
				parameters.Add(new SqlParameter("@" + paramList[i], values[i]));
			}

			return parameters;
		}
		#endregion

		public T GetColumn<T>(string tsql)
		{
			return base.Database.SqlQuery<T>(tsql).FirstOrDefault<T>();
		}

		//public List<T> GetList<T>(string tsql) where T : class
		//{
		//	return base.Database.SqlQuery<T>(tsql).ToList();
		//}

		public DbDataReader ExecuteDbDataReader(string procName, string[] parameters, object[] parameValues)
		{
			throw new NotImplementedException();
		}

		public SqlDataReader ExecuteDataReader(string procName, string[] parameters, object[] parameValues)
		{
			using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["WFMPCP.Connection"].ToString()))
			{
				using (SqlCommand cmd = new SqlCommand())
				{
					con.Open();
					cmd.Connection = con;
					cmd.CommandText = procName;
					cmd.CommandType = CommandType.StoredProcedure;

					if (parameters.Count() > 0)
						for (int i = 0; i < parameters.Count(); i++)
						{
							cmd.Parameters.Add(new SqlParameter("@" + parameters[i], parameValues[i]));
						}

					return cmd.ExecuteReader();
				}
			}
		}

		public List<Dictionary<string, object>> Read(string procName, string[] parameters, object[] parameValues)
		{
			List<Dictionary<string, object>> expandolist = new List<Dictionary<string, object>>();
			using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["WFMPCP.Connection"].ToString()))
			{
				using (SqlCommand cmd = new SqlCommand())
				{
					con.Open();
					cmd.Connection = con;
					cmd.CommandText = procName;
					cmd.CommandType = CommandType.StoredProcedure;

					if (parameters.Count() > 0)
						for (int i = 0; i < parameters.Count(); i++)
						{
							cmd.Parameters.Add(new SqlParameter("@" + parameters[i], parameValues[i]));
						}

					SqlDataReader reader = cmd.ExecuteReader();
					foreach (var item in reader)
					{
						IDictionary<string, object> expando = new ExpandoObject();
						foreach (PropertyDescriptor propertyDescriptor in TypeDescriptor.GetProperties(item))
						{
							var obj = propertyDescriptor.GetValue(item);
							expando.Add(propertyDescriptor.Name, obj);
						}
						expandolist.Add(new Dictionary<string, object>(expando));
					}
				}
			}
			//reader.Close();
			return expandolist;
		}

		#region Dapper ORM
		public void ExecuteTSQL(string tsql)
		{
			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				con.Execute(tsql, commandTimeout: 1800);
			}
		}

		public void Execute(string procName, string[] parameters, object[] paramValues)
		{
			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				con.Execute(procName,
							this.DapperParameters(parameters, paramValues),
							commandType: CommandType.StoredProcedure,
							commandTimeout: 1800);
			}
		}

		public T GetScalar<T>(string tsql)
		{
			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				return con.ExecuteScalar<T>(tsql, commandTimeout: 1800);
			}
		}

		public T Get<T>(string tsql) where T : class
		{
			T item = null;
			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				item = con.QueryFirstOrDefault(tsql, commandTimeout: 1800);
			}
			return item;
		}

		public List<T> GetList<T>(string tsql) where T : class
		{
			List<T> items = null;
			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				items = con.Query<T>(tsql, commandTimeout: 1800).ToList();
			}
			return items;
		}

		public T Get<T>(string procName, string[] parameters, object[] paramValues) where T : class
		{
			T item = null;
			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				item = (T)Convert.ChangeType(con.QueryFirstOrDefault(procName,
																	 this.DapperParameters(parameters, paramValues),
																	 commandType: CommandType.StoredProcedure,
																	 commandTimeout: 1800), typeof(T));
			}

			return item;
		}
		public List<T> GetList<T>(string procName, string[] parameters, object[] paramValues) where T : class
		{
			List<T> items = null;

			using (SqlConnection con = new SqlConnection(Datasource.WFMDatasource))
			{
				items = con.Query<T>(procName,
									 this.DapperParameters(parameters, paramValues),
									 commandType: CommandType.StoredProcedure,
									 commandTimeout: 1800).ToList();
			}

			return items;
		}
		public DynamicParameters DapperParameters(string[] parameters, object[] paramValues)
		{
			DynamicParameters retValues = new DynamicParameters();

			if (parameters.Length == 0)
				retValues = null;
			else
				for (int i = 0; i < parameters.Length; i++)
				{
					retValues.Add(string.Format("@{0}", parameters[i]), paramValues[i]);
				}

			return retValues;
		}
		#endregion

		#endregion IWFMPCPContext
	}
}