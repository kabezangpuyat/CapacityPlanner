using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
	public class DynamicFormulaMapping : EntityTypeConfiguration<DynamicFormula>
	{
		public DynamicFormulaMapping()
		{
			this.ToTable("DynamicFormula")
				.HasKey(x => x.ID);

			this.Property(x => x.ID).HasColumnName("ID");
			this.Property(x => x.Name).HasColumnName("Name");
			this.Property(x => x.Description).HasColumnName("Description");
			this.Property(x => x.Active).HasColumnName("Active");
			this.Property(x => x.DateCreated).HasColumnName("DateCreated").IsOptional();
			this.Property(x => x.DateModified).HasColumnName("DateModified");
		}
	}
}
