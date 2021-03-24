using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class UserRoleMapping : EntityTypeConfiguration<UserRole>
    {
        public UserRoleMapping()
        {
            this.ToTable( "UserRole" )
               .HasKey( x => x.ID );

            this.Property( p => p.ID ).HasColumnName( "ID" );
            this.Property( p => p.RoleID ).HasColumnName( "RoleID" );
            this.Property( p => p.NTLogin ).HasColumnName( "NTLogin" );
            this.Property( p => p.EmployeeID ).HasColumnName( "EmployeeID" );
            this.Property( p => p.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( p => p.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( p => p.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( p => p.DateModified ).HasColumnName( "DateModified" ).IsOptional();
            this.Property( p => p.Active ).HasColumnName( "Active" );

            //role mapping
            this.HasRequired( x => x.Role )
                .WithMany( x => x.UserRoles )
                .HasForeignKey( x => x.RoleID );
        }
    }
}
