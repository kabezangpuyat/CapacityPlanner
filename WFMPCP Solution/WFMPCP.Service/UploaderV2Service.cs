using ExcelService;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using WFMPCP.Core;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using System.Configuration;


namespace WFMPCP.Service
{
    public class UploaderV2Service
	{
		private IWFMPCPContext _context;
		private ExcelReader _exr = null;
		private DataTable _xlsTable;
		private int fileID = 0;
		//private static Vertical vertical;
		public string errMessage = string.Empty;
		private string newSheet = string.Empty;
		private string originalFilename = string.Empty;
		private string weekNumber = string.Empty;
		private bool isSuccess = false;
		public string _uploadMessage = "";
		private StagingWeeklyDatapointService _stagingWeeklyDatapointService;
		private AssumptionHeadcountService _achService;

		#region Constructor
		public UploaderV2Service()
		{
			this._context=new WFMPCPContext();
			this._stagingWeeklyDatapointService = new StagingWeeklyDatapointService(new WFMPCPContext());
			this._achService = new AssumptionHeadcountService(new WFMPCPContext());
			//this._exr = new ExcelReader();
		}
		#endregion

		#region Method(s)
		public bool ExcelRead(string fileName, string column, int columns)
		{
			//check excel reader if null
			if (_exr != null)
			{
				//dispose excel reader
				_exr.Dispose();

				//set excel reader to null
				_exr = null;
			}

			//create new instance of excel reader 
			_exr = new ExcelReader();

			//set excel filename
			_exr.ExcelFilename = fileName;

			//read headers
			_exr.Headers = false;
			_exr.MixedData = false;

			//get set sheet Name to string array
			//_exr = new ExcelReader();
			string[] sheetNames = _exr.GetExcelSheetNames();
			StringBuilder sb = new StringBuilder();

			if (sheetNames == null || string.IsNullOrEmpty(sheetNames[0]))
				throw new Exception("Null Array for excel sheet name....");
			else
			{
				foreach (string sheet in sheetNames)
				{
					if (sheet.Length < 50)
					{
						//replace invalid character from sheetname  
						newSheet = sheet.Replace("$", "")
							.Replace("'", "");

						#region PCP
						//check if data table is null
						if (_xlsTable == null)
						{
							//set new instance for datatable
							_xlsTable = new DataTable();
						}

						//set excel reader connection open
						_exr.KeepConnectionOpen = true;

						//set excel sheet Name to read
						_exr.SheetName = newSheet.ToString();

						//set excel sheet range
						//_exr.SheetRange = Settings.Column + ":" + Settings.Row;
						_exr.SheetRange = string.Format("{0}:{1}", ConfigurationManager.AppSettings["WFMStartColumn"]
															, ConfigurationManager.AppSettings["WFMEndColumn"]);

						var lastColumn = new String(ConfigurationManager.AppSettings["WFMEndColumn"].Where(Char.IsLetter).ToArray());
						var colIndex = this.ExcelColumnNameToNumber(lastColumn) - 3;
						//get record from excel sheet
						_xlsTable = _exr.GetTable();
						int count = _xlsTable.Rows.Count;

						DataRow dateDataRow = _xlsTable.Rows[0];
						List<DateTime> dates = new List<DateTime>();

						#region setup SiteID,CampaignID,LoBID
						string[] splittedSheet = newSheet.Split('>');
						long siteID = long.Parse(splittedSheet[0]);
						long campaignID = long.Parse(splittedSheet[1]);
						long lobID = long.Parse(splittedSheet[2]);
						#endregion

						#region Truncate table first
						_context.ExecuteTSQL("DELETE FROM StagingWeeklyAHDatapoint");
						#endregion

						#region Setup Excel data

						for (int i = 1; i < count; i++)
						{
							DataRow row = _xlsTable.Rows[i];

							#region Loop Column
							for (int j = 0; j <= colIndex; j++)
							{
								string dtString = this.FormattedDateString(dateDataRow[j].ToString());

								DateTime date = DateTime.Parse(dtString);
								if (date.DayOfWeek == DayOfWeek.Monday)
								{
									//insert data
									string data = row[j].ToString().Trim();
									if (string.IsNullOrEmpty(data))
										data = "0";

									data = data.Replace("%", "").Replace(" ", "").Replace(",", "");

									int week = 0;
									week = this.GetWeekOfYear(date);
									dates.Add(date);
									var model = new Model.WeeklyDatapointViewModel()
									{
										SiteID = siteID,
										CampaignID = campaignID,
										LoBID = lobID,
										DatapointID = i,
										Week = week,
										Data = data,
										Date = date,
										CreatedBy = "WFM PCP Uploader",
										DateCreated = DateTime.Now
									};
									_stagingWeeklyDatapointService.Save(model);
								}
							}
							#endregion
						}

						#endregion

						#region Save to WeeklyAHDatapoint
						foreach (var dt in dates.OrderBy(x => x.Date).Distinct())
						{
							#region Create Dataset
							//DataTable datatable = this.WeeklyDtpDatatable;
							DataTable datatable = new DataTable();
							//dataset.Tables.Add( "AHCData" );

							datatable.Columns.Add("DatapointID", typeof(long));
							datatable.Columns.Add("SiteID", typeof(long));
							datatable.Columns.Add("CampaignID", typeof(long));
							datatable.Columns.Add("LoBID", typeof(long));
							datatable.Columns.Add("Date", typeof(DateTime));
							//datatable.Columns.Add( "Date", typeof( string ) );
							datatable.Columns.Add("DataValue", typeof(string));
							datatable.Columns.Add("UserName", typeof(string));
							datatable.Columns.Add("DateModified", typeof(DateTime));

							DataRow datarow;
							#endregion
							string b = dt.ToString("yyyy-MM-dd");
							//get staging data
							var stagingDatapoints = _context.AsQueryable<StagingWeeklyDatapoint>()
								.Where(x => x.Date == dt && x.SiteID == siteID && x.CampaignID == campaignID && x.LoBID == lobID)
								.ToList();

							foreach (var sDatapoint in stagingDatapoints)
							{
								string value = sDatapoint.Data.Replace("%", "").Trim();

								datarow = datatable.NewRow();
								datarow["DatapointID"] = sDatapoint.DatapointID;
								datarow["SiteID"] = sDatapoint.SiteID;
								datarow["CampaignID"] = sDatapoint.CampaignID;
								datarow["LoBID"] = sDatapoint.LoBID;
								datarow["Date"] = dt;
								datarow["DataValue"] = value;
								datarow["UserName"] = sDatapoint.CreatedBy;
								datarow["DateModified"] = sDatapoint.DateCreated;

								datatable.Rows.Add(datarow);
								var bb = datatable;
							}
							_achService.Save(datatable);
						}
						#endregion

						isSuccess = true;
						#endregion

						#region Log
						this.WriteLogs(ref sb, fileName, siteID.ToString(), campaignID.ToString(), lobID.ToString());
						//sb.AppendLine( WriteLogs( fileName, siteID.ToString(), campaignID.ToString(), lobID.ToString() ) );
						//sb.AppendLine(  );
						#endregion
					}
				}
			}
			
			if (sb != null)
			{
				string filename = string.Format("Success_{0}.txt", (DateTime.Now).ToString("MM.dd.yyyy.HH.mm"));
				string filelocation = "";// AppSettings.Setting<string>("WFMUpload.Logs") + filename;

				File.WriteAllText(filelocation, sb.ToString());
			}
			return true;
		}
		public bool ExcelRead2(string fileName, string column, int columns)
		{
			//check excel reader if null
			if (_exr != null)
			{
				//dispose excel reader
				_exr.Dispose();

				//set excel reader to null
				_exr = null;
			}

			//create new instance of excel reader 
			_exr = new ExcelReader();

			//set excel filename
			_exr.ExcelFilename = fileName;

			//read headers
			_exr.Headers = false;
			_exr.MixedData = false;

			//get set sheet Name to string array
			//_exr = new ExcelReader();
			string[] sheetNames = _exr.GetExcelSheetNames();
			StringBuilder sb = new StringBuilder();
			foreach (string sheet in sheetNames)
			{
				if (sheet.Length < 50)
				{
					//replace invalid character from sheetname  
					newSheet = sheet.Replace("$", "")
						.Replace("'", "");

					#region PCP
					//check if data table is null
					if (_xlsTable == null)
					{
						//set new instance for datatable
						_xlsTable = new DataTable();
					}

					//set excel reader connection open
					_exr.KeepConnectionOpen = true;

					//set excel sheet Name to read
					_exr.SheetName = newSheet.ToString();

					//set excel sheet range
					//_exr.SheetRange = Settings.Column + ":" + Settings.Row;
					_exr.SheetRange = string.Format("{0}:{1}", ConfigurationManager.AppSettings["WFMStartColumn"]
														, ConfigurationManager.AppSettings["WFMEndColumn"]);

					var lastColumn = new String(ConfigurationManager.AppSettings["WFMEndColumn"].Where(Char.IsLetter).ToArray());
					var colIndex = this.ExcelColumnNameToNumber(lastColumn) - 3;
					//get record from excel sheet
					_xlsTable = _exr.GetTable();
					int count = _xlsTable.Rows.Count;

					DataRow dateDataRow = _xlsTable.Rows[0];
					List<DateTime> dates = new List<DateTime>();

					#region setup SiteID,CampaignID,LoBID
					string[] splittedSheet = newSheet.Split('>');
					long siteID = long.Parse(splittedSheet[0]);
					long campaignID = long.Parse(splittedSheet[1]);
					long lobID = long.Parse(splittedSheet[2]);
					#endregion

					#region Truncate table first
					_context.ExecuteTSQL("DELETE FROM StagingWeeklyAHDatapoint");
					#endregion

					#region Setup Excel data

					for (int i = 1; i < count; i++)
					{
						DataRow row = _xlsTable.Rows[i];

						#region Loop Column
						for (int j = 0; j <= colIndex; j++)
						{
							string dtString = this.FormattedDateString(dateDataRow[j].ToString());

							DateTime date = DateTime.Parse(dtString);
							if (date.DayOfWeek == DayOfWeek.Monday)
							{
								//insert data
								string data = row[j].ToString().Trim();
								if (string.IsNullOrEmpty(data))
									data = "0";

								data = data.Replace("%", "").Replace(" ", "").Replace(",", "");

								int week = 0;
								week = this.GetWeekOfYear(date);
								dates.Add(date);
								var model = new Model.WeeklyDatapointViewModel()
								{
									SiteID = siteID,
									CampaignID = campaignID,
									LoBID = lobID,
									DatapointID = i,
									Week = week,
									Data = data,
									Date = date,
									CreatedBy = "WFM PCP Uploader",
									DateCreated = DateTime.Now
								};
								_stagingWeeklyDatapointService.Save(model);
							}
						}
						#endregion
					}

					#endregion

					#region Save to WeeklyAHDatapoint
					foreach (var dt in dates.OrderBy(x => x.Date).Distinct())
					{
						#region Create Dataset
						//DataTable datatable = this.WeeklyDtpDatatable;
						DataTable datatable = new DataTable();
						//dataset.Tables.Add( "AHCData" );

						datatable.Columns.Add("DatapointID", typeof(long));
						datatable.Columns.Add("SiteID", typeof(long));
						datatable.Columns.Add("CampaignID", typeof(long));
						datatable.Columns.Add("LoBID", typeof(long));
						datatable.Columns.Add("Date", typeof(DateTime));
						//datatable.Columns.Add( "Date", typeof( string ) );
						datatable.Columns.Add("DataValue", typeof(string));
						datatable.Columns.Add("UserName", typeof(string));
						datatable.Columns.Add("DateModified", typeof(DateTime));

						DataRow datarow;
						#endregion
						string b = dt.ToString("yyyy-MM-dd");
						//get staging data
						var stagingDatapoints = _context.AsQueryable<StagingWeeklyDatapoint>()
							.Where(x => x.Date == dt && x.SiteID == siteID && x.CampaignID == campaignID && x.LoBID == lobID)
							.ToList();

						foreach (var sDatapoint in stagingDatapoints)
						{
							string value = sDatapoint.Data.Replace("%", "").Trim();

							datarow = datatable.NewRow();
							datarow["DatapointID"] = sDatapoint.DatapointID;
							datarow["SiteID"] = sDatapoint.SiteID;
							datarow["CampaignID"] = sDatapoint.CampaignID;
							datarow["LoBID"] = sDatapoint.LoBID;
							datarow["Date"] = dt;
							datarow["DataValue"] = value;
							datarow["UserName"] = sDatapoint.CreatedBy;
							datarow["DateModified"] = sDatapoint.DateCreated;

							datatable.Rows.Add(datarow);
							var bb = datatable;
						}
						_achService.Save(datatable);
					}
					#endregion

					isSuccess = true;
					#endregion

					#region Log
					this.WriteLogs(ref sb, fileName, siteID.ToString(), campaignID.ToString(), lobID.ToString());
					//sb.AppendLine( WriteLogs( fileName, siteID.ToString(), campaignID.ToString(), lobID.ToString() ) );
					//sb.AppendLine(  );
					#endregion
				}
			}
			if (sb != null)
			{
				string filename = string.Format("Success_{0}.txt", (DateTime.Now).ToString("MM.dd.yyyy.HH.mm"));
				string filelocation = ConfigurationManager.AppSettings["WFMUpload.Logs"] + filename;

				File.WriteAllText(filelocation, sb.ToString());
			}
			return true;
		}
		#endregion

		#region Private Method(s)
		private void WriteLogs(ref StringBuilder sb, string fileToUpload, string siteid, string campaignid, string lobid)
		{
			sb.AppendLine("Date: " + (DateTime.Now).ToString("MM/dd/yyyy HH:mm"));
			sb.AppendLine("Filename: " + fileToUpload);
			sb.AppendLine("SiteID:" + siteid);
			sb.AppendLine("CampaignID:" + campaignid);
			sb.AppendLine("LoBID:" + lobid);
			sb.AppendLine("Message: Successfully uploaded.");
			sb.AppendLine("===================================");
			sb.AppendLine("");
		}
		private DataTable WeeklyDtpDatatable
		{
			get
			{
				DataTable datatable = new DataTable();
				//dataset.Tables.Add( "AHCData" );

				datatable.Columns.Add("DatapointID", typeof(long));
				datatable.Columns.Add("SiteID", typeof(long));
				datatable.Columns.Add("CampaignID", typeof(long));
				datatable.Columns.Add("LoBID", typeof(long));
				datatable.Columns.Add("Date", typeof(DateTime));
				//datatable.Columns.Add( "Date", typeof( string ) );
				datatable.Columns.Add("DataValue", typeof(string));
				datatable.Columns.Add("UserName", typeof(string));
				datatable.Columns.Add("DateModified", typeof(DateTime));
				string datemodified = DateTime.Now.ToString();

				return datatable;
			}
		}
		private string CheckIfNull(string value)
		{
			string returnValue;

			value = value.Replace("%", "");

			if (value == string.Empty)
			{
				returnValue = null;
			}
			else
			{
				returnValue = value;
			}
			return returnValue;
		}

		private string CheckIfNullPercentage(string value)
		{
			string returnValue;

			value = value.Replace("%", "");

			if (value == string.Empty)
			{
				returnValue = null;
			}
			else
			{
				value = (Decimal.Parse(value, System.Globalization.NumberStyles.Float) * 100).ToString();
				returnValue = value;
			}
			return returnValue;
		}

		private void singleColumnErr(string strVal, string column)
		{
			try
			{
				Convert.ToSingle(strVal);
			}
			catch
			{
				DownloadExcel.errMessage = "Error uploading " + originalFilename + " | Worksheet Name : " +
					newSheet + " | " + weekNumber + " -  Column " + column + " should be decimal/numbers only. ";
				isSuccess = true;
				//SendEmail( DownloadExcel.errMessage ); 
			}
		}

		private void decimalColumnErr(string strVal, string column)
		{
			try
			{
				Convert.ToDecimal(strVal);
			}
			catch
			{
				DownloadExcel.errMessage = "Error uploading " + originalFilename + " | Worksheet Name : " +
					newSheet + " | " + weekNumber + " -  Column " + column + " should be decimal/numbers only. ";
				isSuccess = true;
				//SendEmail( DownloadExcel.errMessage );
			}
		}

		private void IntColumn(string strVal, string column)
		{
			try
			{
				Convert.ToInt32(strVal);
			}
			catch
			{
				DownloadExcel.errMessage = "Error uploading " + originalFilename + " | Worksheet Name : " +
					newSheet + " | " + weekNumber + " -  Column " + column + " should be single number only. ";
				isSuccess = true;
				//SendEmail( DownloadExcel.errMessage );
			}
		}

		private int ExcelColumnNameToNumber(string columnName)
		{
			if (string.IsNullOrEmpty(columnName))
				throw new ArgumentNullException("columnName");

			columnName = columnName.ToUpperInvariant();

			int sum = 0;

			for (int i = 0; i < columnName.Length; i++)
			{
				sum *= 26;
				sum += (columnName[i] - 'A' + 1);
			}

			return sum;
		}

		private string FormattedDateString(string init)
		{
			string retValue = string.Empty;

			string[] splitted = init.Split('/');

			string year = splitted[2].Trim();
			string month = splitted[0].Trim();
			string day = splitted[1].Trim();

			//check if month is less > 12 then it's day.
			if (int.Parse(month) > 12)
			{
				month = splitted[1].Trim();
				day = splitted[0].Trim();
			}

			if (year.Length > 4)
				year = splitted[2].Trim().Substring(0, 4);
			if (month.Length < 2)
				month = "0" + splitted[0].Trim();
			if (day.Length < 2)
				day = "0" + splitted[1].Trim();

			retValue = string.Format("{0}-{1}-{2}", year,
												   month,
												   day);

			return retValue;
		}

		private int GetWeekOfYear(DateTime time)
		{
			// Seriously cheat.  If its Monday, Tuesday or Wednesday, then it'll 
			// be the same week# as whatever Thursday, Friday or Saturday are,
			// and we always get those right
			DayOfWeek day = CultureInfo.InvariantCulture.Calendar.GetDayOfWeek(time);
			if (day >= DayOfWeek.Monday && day <= DayOfWeek.Wednesday)
			{
				time = time.AddDays(3);
			}

			// Return the week of our adjusted day
			return CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(time, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
		}
		#endregion
	}
}
