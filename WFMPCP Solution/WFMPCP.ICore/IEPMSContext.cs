using Dapper;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;

namespace WFMPCP.ICore
{
	public interface IEPMSContext : IDisposable
	{
		IQueryable<T> AsQueryable<T>() where T : class;

		T Add<T>(T item) where T : class;

		T Remove<T>(T item) where T : class;

		T Update<T>(T item) where T : class;

		T Attach<T>(T item) where T : class;

		T Detach<T>(T item) where T : class;

		void ExecuteTSQL(string tsql, SqlParameter parameter);


		DbDataReader ExecuteDbDataReader(string procName, string[] parameters, object[] parameValues);

		SqlDataReader ExecuteDataReader(string cmdText, string[] paramList, object[] values, bool isSp = true);

		List<Dictionary<string, object>> Read(string procName, string[] parameters, object[] parameValues);

		int SaveChanges();

		#region Dapper ORM
		void ExecuteTSQL(string tsql);
		T GetScalar<T>(string tsql);
		T Get<T>(string tsql) where T : class;
		List<T> GetList<T>(string tsql) where T : class;
		T Get<T>(string procName, string[] parameters, object[] paramValues) where T : class;
		List<T> GetList<T>(string procName, string[] parameters, object[] paramValues) where T : class;
		DynamicParameters DapperParameters(string[] parameters, object[] paramValues);
		#endregion Dapper ORM
	}
}
