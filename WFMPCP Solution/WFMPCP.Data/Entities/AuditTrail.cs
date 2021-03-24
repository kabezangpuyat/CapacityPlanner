using System;
using System.Collections.Generic;
using System.Text;

namespace WFMPCP.Data.Entities
{
    public class AuditTrail
    {
        public long ID { get; set; }
        public string AuditEntry { get; set; }
        public string CreatedBy { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateModified { get; set; }
    }
}
