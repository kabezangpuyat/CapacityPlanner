using System;
using System.DirectoryServices;
using System.Text;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class ActiveDirectoryService : IActiveDirectoryService
	{
		private readonly IWFMPCPContext _context;

		public ActiveDirectoryService(IWFMPCPContext context)
		{
			this._context = context;
		}

		//public void GetADDetails()
		//{
		//	using (var context = new PrincipalContext(ContextType.Domain, Domain, name, access))
		//	{
		//		using (var user = new UserPrincipal(context))
		//		{
		//			user.SamAccountName = userName.Split('\\').Last();
		//			using (var searcher = new PrincipalSearcher(user))
		//			{
		//				foreach (var result in searcher.FindAll())
		//				{
		//					DirectoryEntry de = result.GetUnderlyingObject() as DirectoryEntry;
		//					ldapUser = new LDAPUser()
		//					{
		//						FirstName = Convert.ToString(de.Properties["givenName"].Value),
		//						LastName = Convert.ToString(de.Properties["sn"].Value),
		//						Email = Convert.ToString(de.Properties["mail"].Value),
		//						Designation = Convert.ToString(de.Properties["title"].Value),
		//						ThumbnailPhoto = de.Properties["thumbnailPhoto"].Value as byte[]
		//					};
		//					return ldapUser;
		//				}
		//			}
		//		}
		//	}
		//}
		public ActiveDirectoryUser Authenticate(string ntLogin, string password)
		{
			ActiveDirectoryUser adUser = new ActiveDirectoryUser();
			string userIdentity = string.Format(@"TU\{0}", ntLogin);
			//"TU\\" + username.ToUpper();
			string employeeID = string.Empty;
			string firstname = string.Empty;
			string lastname = string.Empty;
			byte[] thumbnail = { };

			DirectoryEntry directoryEntry = this.CreateDirectoryEntry(userIdentity, password);//new DirectoryEntry( "LDAP://TU", username, password );
			DirectorySearcher directorySearcher = new DirectorySearcher(directoryEntry);
			directorySearcher.Filter = "(&(ObjectClass=User)(sAMAccountName=" + ntLogin + "))";

			try
			{
				SearchResult adsSearchResult = directorySearcher.FindOne();
				if (adsSearchResult.Properties["employeeID"].Count > 0)
					employeeID = adsSearchResult.Properties["employeeID"][0].ToString();
				if (adsSearchResult.Properties["givenName"].Count > 0)
					firstname = adsSearchResult.Properties["givenName"][0].ToString();
				if (adsSearchResult.Properties["sn"].Count > 0)
					lastname = adsSearchResult.Properties["sn"][0].ToString();

				using (var de = new DirectoryEntry(adsSearchResult.Path))
				{
					thumbnail=de.Properties["thumbnailPhoto"].Value as byte[];
				}
				
				if (ntLogin == "mviray.admin")
					employeeID = "1234567";

				adUser.EmployeeNumber = employeeID;
				adUser.FirstName = firstname;
				adUser.LastName = lastname;
				adUser.ThumbnailPhoto = thumbnail;
			}
			catch (Exception ex)
			{
				//TODO: Log into audit trail
				StringBuilder exceptionMessage = new StringBuilder();
				exceptionMessage.AppendLine(string.Format("Message: {0}", ex.Message));
				exceptionMessage.AppendLine(string.Format("Target Site: {0}", ex.TargetSite));
				exceptionMessage.AppendLine(string.Format("Help Link: {0}", ex.HelpLink));
				exceptionMessage.AppendLine(string.Format("Source: {0}", ex.Source));
				//exceptionMessage.AppendLine( string.Format( "Inner Exception Message: {0}", ex.InnerException.Message ) );

				AuditTrailService auditService = new AuditTrailService(this._context);
				auditService.Create(new Model.AuditTrailViewModel()
				{
					AuditEntry = exceptionMessage.ToString(),
					CreatedBy = "WFM PCP App",
					DateCreated = DateTime.Now,
					DateModified = null
				});

				throw new ArgumentException("Authentication error. Please contact your sysmtem administrator.", ex.InnerException);
			}
			finally
			{
				directoryEntry.Close();
			}

			return adUser;
		}

		public DirectoryEntry CreateDirectoryEntry(string username, string password)
		{
			DirectoryEntry ldapConnection = new DirectoryEntry(@"LDAP://TU");
			ldapConnection.Username = username;
			ldapConnection.Password = password;

			return ldapConnection;
		}
	}
}