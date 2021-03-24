using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Net.Mail;

using System.Data.SqlClient;
using System.Configuration;

namespace ExcelService
{
    public class DownloadExcel
    {
        private static ExcelReader _exr = null;
        private static DataTable _xlsTable;
        private static int fileID = 0;
        //private static Vertical vertical;
        public static string errMessage = string.Empty;
        private static string newSheet = string.Empty;
        private static string originalFilename = string.Empty;
        private static string weekNumber = string.Empty;
        private static bool isSuccess = false;
        public static string _uploadMessage = "";

        public static bool ExcelRead( string fileName, string origFileName, string column, int columns, string musthavesheetname="" )
        {

            errMessage = string.Empty;
            //message = string.Empty;
            originalFilename = Path.GetFileName( origFileName );
            try
            {
                //check excel reader if null
                if ( _exr != null )
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

                //read no headers
                _exr.Headers = false;
                _exr.MixedData = true;

                //get set sheet Name to string array
                //_exr = new ExcelReader();
                string[] sheetNames = _exr.GetExcelSheetNames();

                //read sheet names 
                foreach ( string sheet in sheetNames )
                {
                    //check if sheet Name is true
                    if ( sheet.Length < 50 )
                    {
                        //replace invalid character from sheetname  
                        newSheet = sheet.Replace( "$", "" )
                            .Replace( "'", "" );

                        #region Check here
                        //get LOB id
                        string sheetName = newSheet.Trim().Replace( "_", "" ).ToUpper();
                        //int rowCtr = 0;
                        if ( sheetName.Trim().ToUpper() == "WEIGHT2" )
                        {
                            bool upload = true;
                            if ( !string.IsNullOrEmpty( musthavesheetname ) )
                                if ( musthavesheetname.Trim().ToUpper() != sheetName.Trim().ToUpper() )
                                    upload = false;

                            if ( upload )
                            {
                                #region AKJSSIS
                                //check if data table is null
                                if ( _xlsTable == null )
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
                                _exr.SheetRange = "A2:D38";

                                //get record from excel sheet
                                _xlsTable = _exr.GetTable();
                                int count = _xlsTable.Rows.Count;

                                for ( int i = 0; i <= count; i++ )
                                {
                                    DataRow row = _xlsTable.Rows[i];
                                    //DateTime dt;

                                    string test = "";
                                    if ( CheckIfNull( row[0].ToString() ).Length > 0 )
                                    {
                                        #region Checking per column
                                        string date = row[0].ToString().Trim().Replace( "'", "''" ).Replace( "$", "" );//a
                                        string kg = row[1].ToString().Trim().Replace( "'", "''" ).Replace( "$", "" );//b
                                        string lbs = row[2].ToString().Trim().Replace( "'", "''" ).Replace( "$", "" );//c
                                        string dif = row[3].ToString().Trim().Replace( "'", "''" ).Replace( "$", "" );//d
                                        #endregion

                                        #region Create Capacity Plan Manager
                                        //TODO: INSERT TO TABLE
                                        test += string.Format( "{0}:{1}:{2}:{3}",date,kg,lbs,dif );
                                        #endregion
                                    }
                                }


                                isSuccess = true;
                                #endregion
                            }
                            else
                            {
                                _uploadMessage = "Invalid file template, your uploaded sheetname must be " + musthavesheetname;
                                return false;
                            }
                        }                        
                        else
                        {
                            isSuccess = false;
                            _uploadMessage = string.Format( "Invalid file template for {0}. Please check template sheetname.", origFileName );
                        }
                        #endregion
                    }
                }

                ////lOG USER who upload the data.
                //LogUpload.LoggedTransactionFolder = System.Configuration.ConfigurationManager.AppSettings["WFMGCCP.LogUploadFolder"].ToString();
                //LogUpload.WriteTransaction( PCPSession.Current.LoggedFullName, fileName );

                return isSuccess;
            }
            catch ( Exception ex )
            {
                //throw new ArgumentException( ex.Message );
                ////LogMyError.ErrorFolder = System.Configuration.ConfigurationManager.AppSettings["WFMGCCP.ErrorFolder"].ToString();
                ////LogMyError.WriteError( ex, newSheet );
                //isSuccess = false;
                //string errmessage = ex.Message;
                if ( ex.Message.Contains( "There is no row" ) )
                    return true;

                _uploadMessage = ex.Message;
                return false;
            }
            finally
            {
                _exr.Close();
                _exr.Dispose();
                _exr = null;
            }
        }

        /// <summary>
        /// check value if null
        /// </summary>
        /// <param Name="value"></param>
        /// <returns></returns>
        #region Private Method(s)
        private static string CheckIfNull( string value )
        {
            string returnValue;

            value = value.Replace( "%", "" );

            if( value == string.Empty )
            {
                returnValue = null;
            }
            else
            {
                returnValue = value;
            }
            return returnValue;
        }

        private static string CheckIfNullPercentage( string value )
        {
            string returnValue;

            value = value.Replace( "%", "" );

            if( value == string.Empty )
            {
                returnValue = null;
            }
            else
            {
                value = ( Decimal.Parse( value, System.Globalization.NumberStyles.Float ) * 100 ).ToString();
                returnValue = value;
            }
            return returnValue;
        }

        private static void singleColumnErr( string strVal, string column )
        {
            try
            {
                Convert.ToSingle( strVal );
            }
            catch
            {
                DownloadExcel.errMessage = "Error uploading " + originalFilename + " | Worksheet Name : " +
                    newSheet + " | " + weekNumber + " -  Column " + column + " should be decimal/numbers only. ";
                isSuccess = true;
                //SendEmail( DownloadExcel.errMessage ); 
            }
        }

        private static void decimalColumnErr( string strVal, string column )
        {
            try
            {
                Convert.ToDecimal( strVal );
            }
            catch
            {
                DownloadExcel.errMessage = "Error uploading " + originalFilename + " | Worksheet Name : " +
                    newSheet + " | " + weekNumber + " -  Column " + column + " should be decimal/numbers only. ";
                isSuccess = true;
                //SendEmail( DownloadExcel.errMessage );
            }
        }

        private static void IntColumn( string strVal, string column )
        {
            try
            {
                Convert.ToInt32( strVal );
            }
            catch
            {
                DownloadExcel.errMessage = "Error uploading " + originalFilename + " | Worksheet Name : " +
                    newSheet + " | " + weekNumber + " -  Column " + column + " should be single number only. ";
                isSuccess = true;
                //SendEmail( DownloadExcel.errMessage );
            }
        }

        private static void SendEmail( string msgBody )
        {
            try
            {
                string emailList = string.Empty;

                #region Get email list.
                StreamReader emails =
                        new StreamReader( File.OpenRead( @"C:\WFM\WEB Apps\PCP\EmailList.txt" ) );

                emailList = emails.ReadToEnd();
                emails.Close();

                //remove last comma value 
                if( emailList.Trim().Length > 0 )
                {
                    if( emailList.Trim().Substring( emailList.Trim().Length - 1,
                                        1 ) == "," )
                    {
                        emailList =
                            emailList.Trim().Substring( 1,
                                                      emailList.Trim().Length - 2 );
                    }
                }
                #endregion

                SmtpClient smtpClient = new SmtpClient();
                MailMessage message = new MailMessage();
                MailAddress fromAddress = new MailAddress( "automation1@peoplesupport.com", "PCP Uploading error" );

                // You can specify the host name or ipaddress of your server
                // Default in IIS will be localhost 
                smtpClient.Host = "pscmail01.psmanila.peoplesupport.com";

                //Default port will be 25
                smtpClient.Port = 25;

                //From address will be given as a MailAddress Object
                message.From = fromAddress;

                // To address collection of MailAddress
                message.To.Add( emailList.Trim() );

                message.Subject = "PCP:Error column datatype.";

                //Body can be Html or text format
                //Specify true if it  is html message
                message.IsBodyHtml = true;

                // Message body content
                message.Body = msgBody;

                // Send SMTP mail
                smtpClient.Send( message );
            }
            catch( Exception ex )
            {
                DownloadExcel.errMessage = DownloadExcel.errMessage + ex.Message;
            }
        } 
        #endregion
    }

}
