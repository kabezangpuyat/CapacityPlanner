using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data.SqlClient;
using Dapper;
using System.Text.RegularExpressions;

namespace WFMPOC
{
    class Program
    {
		static void Test1()
		{
			string message = string.Empty;
			bool isError = false;
			try
			{
				message = "File uploaded.";
				throw new Exception("The process cannot access file 'test.csv' because it is being used by another process.");
			}
			catch(Exception ex)
			{
				isError = true;
				//TODO: Log here
				string[] err = { "the process cannot access the file", "because it is being used by another process" };

				if (!string.IsNullOrEmpty(ex.Message))
					if (ex.Message.ToLower().Contains("because it is being used by another process"))
						message += "<br /> File successfully uploaded.";

				//if (err.Contains(ex.Message.ToLower()))
				//	message += "<br /> File successfully uploaded.";

				message += "<br /> Unexpected error encountered. Please contact your system administrator.";
				message += string.Format("<br /> Error: {0}", ex.Message);
			}
			finally
			{
				if (!isError)
					message = "File successfully  uploaded.";
				
			}
			Console.WriteLine(message);
		}
        static void Main( string[] args )
        {
			Test1();
			//ReadCSV();
             Console.ReadKey();
        }
		public static void InsertToStaging(string data, string createdBy, int rowNumber, int colNumber,
			int siteID, int campaignID, int lobID, string fileName)
		{
			string constring = ConfigurationManager.ConnectionStrings["poc.con"].ConnectionString;
			using (SqlConnection con = new SqlConnection(constring))
			{
			
				string qry = string.Format("INSERT INTO CSVRawData(Data,CreatedBy,RowNumber,ColumnNumber,SiteID,CampaignID,LoBID,Filename) VALUES('{0}','{1}',{2},{3},{4},{5},{6},'{7}')",
									data.Replace(",", "").Replace("\"", "").Trim() ,
									createdBy,
									rowNumber,
									colNumber,
									siteID,
									campaignID,
									lobID,
									fileName);
				con.Execute(qry);
			}
		}
		public static void ReadCSV()
		{
			
			try
			{
				string filePath = @"C:\_work\WFM_PCP\trunk\WFMPCP Solution\WFMPOC\UploadedFiles\2.41.135.csv";
				string filename = Path.GetFileNameWithoutExtension(filePath);

				using (StreamReader sr = new StreamReader(filePath))
				{
					string currentLine;
					string[] siteCampaignLobIds = filename.Split('.');

					int siteID = Convert.ToInt32(siteCampaignLobIds[0]);
					int campaignID = Convert.ToInt32(siteCampaignLobIds[1]);
					int lobID = Convert.ToInt32(siteCampaignLobIds[2]);
					string segmentName = string.Empty;

					int col = 0;
					int row = 0;
					int ctr = 0;
					// currentLine will be null when the StreamReader reaches the end of file
					Regex regx = new Regex(",(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))");
					while ((currentLine = sr.ReadLine()) != null)
					{						
						string[] splitted = regx.Split(currentLine);

						//currentLine.Split(',');
						foreach (var data in splitted)
						{
							col++;
							ctr++;
							string value = data.Replace("%", "").Replace("#VALUE!", "").Replace("#DIV/0!","")
								.Replace("-", "").Trim();


							#region Setup Date
							if (row==1 && col>2)
							{
								//Header
								string[] splittedDate = data.Trim().Split('/');
								string mm = splittedDate[0].ToString().Trim().Length==1 ? ("0"+splittedDate[0].ToString()) : splittedDate[0].ToString().Trim();
								string dd = splittedDate[1].ToString().Trim().Length==1 ? ("0"+splittedDate[1].ToString()) : splittedDate[1].ToString().Trim();
								string yyyy = splittedDate[2].ToString();

								value = string.Format("{0}-{1}-{2}", yyyy, mm, dd);
							}
							#endregion

							if (col==1)
							{
								if (!string.IsNullOrEmpty(value))
									segmentName = value;

								value = segmentName;
								row++;
								Console.WriteLine("*********************");
								Console.WriteLine(string.Format("ROW {0}", row));
								Console.WriteLine("*********************");								
							}
							if (string.IsNullOrEmpty(value))
								value = "0";

							Console.WriteLine(string.Format("Col: {0} ==== Value: {1} ==== ctr: {2}",col,value,ctr));
							InsertToStaging(value, 
											"Test",
											row,
											col,
											siteID,
											campaignID,
											lobID,
											string.Format("{0}.csv",filename));

							if (col==46)
							{
								col=0;
							}


							


						}

					}
				}
			}
			catch (Exception e)
			{
				Console.WriteLine("The File could not be read:");
				Console.WriteLine(e.Message);

				Console.ReadLine();
			}

		}

		public static void Test()
		{

			string a = @"<div>xxx -6409571164445 xxx</div>";
			string b = GetBetween(a, "xxx", "xxx");

			Console.WriteLine(b);

			////DateTime today = DateTime.Today;
			////DateTime endOfMonth = new DateTime( today.Year,
			////                                   today.Month,
			////                                   DateTime.DaysInMonth( today.Year,
			////                                                        today.Month ) );

			////DateTime date = DateTime.Parse("2016 -11-10");
			//var firstMonday = GetFirstMondayOfMonth( date );            
			//var firstmondaystring = string.Format( "First Mon NOV 2016 {0} - {1}", firstMonday.ToString( "yyyy-MM-dd" ), firstMonday.DayOfWeek );
			//var lastMonday = GetLastMondayOfMonth( date );
			//var lastmondaystring = string.Format( "Last Mon NOV 2016 {0} - {1}", lastMonday.ToString( "yyyy-MM-dd" ), lastMonday.DayOfWeek );

			//DateTime date2 = DateTime.Parse( "2017-08-10" );
			//var firstMonday2 = GetFirstMondayOfMonth( date2 );
			//var firstmondaystring2 = string.Format( "First Mon AUG 2017 {0} - {1}", firstMonday2.ToString( "yyyy-MM-dd" ), firstMonday2.DayOfWeek );
			//var lastMonday2 = GetLastMondayOfMonth( date2 );
			//var lastmondaystring2 = string.Format( "Last Mon AUG 2017 {0} - {1}", lastMonday2.ToString( "yyyy-MM-dd" ), lastMonday2.DayOfWeek );


			//DateTime date3 = DateTime.Parse( "2016-12-10" );
			//var firstMonday3 = GetFirstMondayOfMonth( date3 );
			//var firstmondaystring3 = string.Format( "First Mon DEC 2016 {0} - {1}", firstMonday3.ToString( "yyyy-MM-dd" ), firstMonday3.DayOfWeek );
			//var lastMonday3 = GetLastMondayOfMonth( date3 );
			//var lastmondaystring3 = string.Format( "Last Mon DEC 2016 {0} - {1}", lastMonday3.ToString( "yyyy-MM-dd" ), lastMonday3.DayOfWeek );

			//DateTime date4 = DateTime.Parse( "2017-09-10" );
			//var firstMonday4 = GetFirstMondayOfMonth( date4 );
			//var firstmondaystring4 = string.Format( "First Mon SEP 2017 {0} - {1}", firstMonday4.ToString( "yyyy-MM-dd" ), firstMonday4.DayOfWeek );
			//var lastMonday4 = GetLastMondayOfMonth( date4 );
			//var lastmondaystring4 = string.Format( "Last Mon SEP 2017 {0} - {1}", lastMonday4.ToString( "yyyy-MM-dd" ), lastMonday4.DayOfWeek );

			//DateTime date5 = DateTime.Parse( "2017-10-10" );
			//var firstMonday5 = GetFirstMondayOfMonth( date5 );
			//var firstmondaystring5 = string.Format( "First Mon SEP 2017 {0} - {1}", firstMonday5.ToString( "yyyy-MM-dd" ), firstMonday5.DayOfWeek );
			//var lastMonday5 = GetLastMondayOfMonth( date5 );
			//var lastmondaystring5 = string.Format( "Last Mon SEP 2017 {0} - {1}", lastMonday5.ToString( "yyyy-MM-dd" ), lastMonday5.DayOfWeek );


			//Console.WriteLine( firstmondaystring );
			//Console.WriteLine( lastmondaystring );
			//Console.WriteLine( "" );

			//Console.WriteLine( firstmondaystring3 );
			//Console.WriteLine( lastmondaystring3 );
			//Console.WriteLine( "" );

			//Console.WriteLine( firstmondaystring2 );
			//Console.WriteLine( lastmondaystring2 );
			//Console.WriteLine( "" );

			//Console.WriteLine( firstmondaystring4 );
			//Console.WriteLine( lastmondaystring4 );
			//Console.WriteLine( "" );

			//Console.WriteLine( firstmondaystring5 );
			//Console.WriteLine( lastmondaystring5 );

			//Console.WriteLine( lastMondayOfMonth.ToString( "yyyy-MM-dd" ) );
			//Console.WriteLine( lastMondayOfMonth.DayOfWeek.ToString() );
		}
		public static string GetBetween( string source, string start, string end )
        {
            int Start, End;
            if( source.Contains( start ) && source.Contains( end ) )
            {
                Start = source.IndexOf( start, 0 ) + start.Length;
                End = source.IndexOf( end, Start );
                return source.Substring( Start, End - Start ).Trim();
            }
            else
            {
                return "";
            }
        }
        public static DateTime GetFirstMondayOfMonth( DateTime now )
        {
            var firstDayOfMonth = new DateTime( now.Year, now.Month, 1 );
            var monday = firstDayOfMonth;

            var ctr = 1;
            if( firstDayOfMonth.DayOfWeek == DayOfWeek.Tuesday || firstDayOfMonth.DayOfWeek == DayOfWeek.Wednesday
                || firstDayOfMonth.DayOfWeek == DayOfWeek.Thursday )
                ctr = -1;

            while( monday.DayOfWeek != DayOfWeek.Monday )
                monday = monday.AddDays( ctr );

            return monday;
        } 

        public static DateTime GetLastMondayOfMonth( DateTime now )
        {
            var lastDayOfMonth = new DateTime( now.Year, now.Month, DateTime.DaysInMonth( now.Year, now.Month ) );
            var monday = lastDayOfMonth;
                        
            while( monday.DayOfWeek != DayOfWeek.Monday )
            {
                monday = monday.AddDays( -1 );
            }

            //once you get the last monday of month get the difference between lastmonday and lastday
            var dateDiff = ( lastDayOfMonth - monday ).TotalDays + 1;

            if( dateDiff < 4 )
            {
                monday = monday.AddDays( -1 );
                while( monday.DayOfWeek != DayOfWeek.Monday )
                {
                    monday = monday.AddDays( -1 );
                }
            }
            return monday;
        }


//CREATE TABLE StagingAssumptionsAndHeadcount
//(
//ID BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT[pk_ID] PRIMARY KEY([ID]),
//SiteID BIGINT,
//CampaignID BIGINT,
//LoBID BIGINT,
//RowNumber BIGINT,
//ColumnNumber BIGINT,
//Data NVARCHAR(150) NULL,
//CreatedBy NVARCHAR(150),
//DateCreated DATETIME NOT NULL  DEFAULT GETDATE()
//);
//);
    }
}
