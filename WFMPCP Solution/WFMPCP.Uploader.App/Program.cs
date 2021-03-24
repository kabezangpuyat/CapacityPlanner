using System;
using System.IO;
using System.Linq;
using System.Text;
using WFMPCP.Uploader.App.Operations;
using WFMPCP.Model;
using System.Configuration;

namespace WFMPCP.Uploader.App
{
	internal class Program
	{
		//private static IUploadAHCService _uploadService;
		private static void Main(string[] args)
		{
			AHCUploaderOperation ops = new AHCUploaderOperation();

			var erlangVM = ops.CalculateErlang(200, 180, 80, 20, 30);

			if (erlangVM != null)
			{
				Console.WriteLine($"Number of agents required: {erlangVM.NumberOfAgentsRequired}");
				Console.WriteLine($"ServiceLevel: {erlangVM.ServiceLevel}");
				Console.WriteLine($"ServiceLevel %: {erlangVM.ServiceLevelPerc}");
				Console.WriteLine($"Pw/Erlang: {erlangVM.PwErlang}");
				Console.WriteLine($"Probability of Call to Wait: {erlangVM.PwErlangPerc}");
				Console.WriteLine($"ASA: {erlangVM.ASA}");
				Console.WriteLine($"Immediate Answer %: {erlangVM.ImmediateAnswerPerc}");
				Console.WriteLine($"TargetAnswerTimeInSecs: {erlangVM.TargetAnswerTimeInSecond}");
				Console.WriteLine($"AHT in Secs: {erlangVM.AHTSec}");
				Console.WriteLine($"Required SL %: {erlangVM.RequiredServiceLevelPerc}");
				Console.WriteLine($"N: {erlangVM.N}");
				Console.WriteLine($"X: {erlangVM.X}");
				Console.WriteLine($"Y: {erlangVM.Y}");
				Console.WriteLine($"A: {erlangVM.A}");
				Console.WriteLine($"Occupancy %: {erlangVM.OccupancyPerc}");
			}
			else
				Console.WriteLine("Empty");

			Console.ReadKey();
		
		}
		private static void Main2(string[] args)
		{
			AHCUploaderOperation uploadOperation = new AHCUploaderOperation();

			bool success = false;
			string message = string.Empty;
			var dir = ConfigurationManager.AppSettings["WFMUpload.Dir"].ToString();
			var directory = new DirectoryInfo(dir);
			var fileToUpload = directory.GetFiles()
							.Where(x => x.Extension.ToLower() == ".xls")
							 .OrderByDescending(f => f.LastWriteTime)
							 .FirstOrDefault();

			try
			{
				Console.WriteLine("Processing...");
				//success = new WFMPCP.Service.UploaderV2Service().ExcelRead(fileToUpload.FullName, "", 1);
				//success = uploadOperation.Upload(fileToUpload.FullName, "", "", 1);
				//string filepath = AppSettings.Setting<string>("WFMUpload.TestFile");
				//filepath=@"C:\_work\WFM_PCP\trunk\WFMPCP Solution\WFMPOC\UploadedFiles\1.1.1.csv";
				success = uploadOperation.UploadCSV(@"C:\_work\WFM_PCP\trunk\WFMPCP Solution\WFMPCP.Uploader.App\UploadedFiles\1.1.1.csv", "mv1604993");
				//success = true;

				if (success == true)
				{
					//StringBuilder sb = new StringBuilder();

					//sb.AppendLine( "Date: " + ( DateTime.Now ).ToString( "MM/dd/yyyy HH:mm" ) );
					//sb.AppendLine( "Filename: " + fileToUpload );
					//sb.AppendLine( "Message: Successfully uploaded." );

					//string filename = string.Format( "Success_{0}.txt", ( DateTime.Now ).ToString( "MM.dd.yyyy.HH.mm" ) );
					//string filelocation = AppSettings.Setting<string>( "WFMUpload.Logs" ) + filename;

					//File.WriteAllText( filelocation, sb.ToString() );

					message = "File uploaded.";
				}
			}
			catch (Exception ex)
			{
				message = ex.Message;
				StringBuilder sb = new StringBuilder();
				sb.AppendLine("Date: " + (DateTime.Now).ToString("MM/dd/yyyy HH:mm"));
				sb.AppendLine("Filename: " + fileToUpload);
				sb.AppendLine("ErrorMessage: " + ex.Message);
				sb.AppendLine("TargetName: " + ex.TargetSite.Name);
				sb.AppendLine("StackTrace: " + ex.StackTrace);

				string filename = string.Format("Error_{0}.txt", (DateTime.Now).ToString("MM.dd.yyyy.HH.mm"));
				string filelocation = ConfigurationManager.AppSettings["WFMUpload.Logs"] + filename;

				File.WriteAllText(filelocation, sb.ToString());
			}
			Console.WriteLine(message);
			Console.ReadKey();
		}
	}
}