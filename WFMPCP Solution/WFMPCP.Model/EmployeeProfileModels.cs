using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Model
{
    #region User
    public class UserResult
    {
        public int ID { get; set; }
        public string EmployeeID { get; set; }
        public string FullName { get; set; }
        public string UserLevel { get; set; }
        public string Password { get; set; }
        public string Campaign { get; set; }
        public string LoB { get; set; }
        public string Others { get; set; }
        public string Email { get; set; }
        public string MobilePhone { get; set; }
        public string ADLogin { get; set; }
        public string Field1 { get; set; }
        public string RoleName { get; set; }
    }
    #endregion

    #region UserDetails
    public class UserDetailSuperiorResult
    {
        public int ID { get; set; }
        public int EmployeeID { get; set; }
        public string Name { get; set; }
        public string Position { get; set; }
        public string SupEmployeeID { get; set; }
    }

    public class UserDetailResult
    {
        public int ID { get; set; }
        public int EmployeeID { get; set; }
        public string LastName { get; set; }
        public string MiddleName { get; set; }
        public string FirstName { get; set; }
        public string FullName { get; set; }
        public string JobDescription { get; set; }
        public string Campaign { get; set; }
        public string LoB { get; set; }
        public string CampaignCategory { get; set; }
        public string Location { get; set; }
        public string Site { get; set; }
        public string ISID { get; set; }
        public string ISLastName { get; set; }
        public string ISFirstName { get; set; }
        public string CoachID { get; set; }
        public string CoachName { get; set; }
        public string QAID { get; set; }
        public string QAName { get; set; }
        public string TrainerID { get; set; }
        public string TrainerName { get; set; }
        public string OperationsManager { get; set; }
        public string SeniorOperationsManager { get; set; }
        public string Status { get; set; }
        public string Department { get; set; }
        public int? StatusApproval { get; set; }
    }
    #endregion
}
