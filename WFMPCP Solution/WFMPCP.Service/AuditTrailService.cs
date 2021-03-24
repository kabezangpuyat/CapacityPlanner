using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class AuditTrailService : IAuditTrailService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public AuditTrailService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<AuditTrailViewModel> GetAll()
		{
			var data = _context.AsQueryable<AuditTrail>()
				.Select(x => new AuditTrailViewModel()
				{
					ID = x.ID,
					AuditEntry = x.AuditEntry,
					CreatedBy = x.CreatedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified
				}).AsQueryable();

			return data;
		}

		public AuditTrailViewModel GetByID(int id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public AuditTrailViewModel Create(AuditTrailViewModel model)
		{
			var data = new AuditTrail()
			{
				AuditEntry = model.AuditEntry,
				CreatedBy = model.CreatedBy,
				DateCreated = model.DateCreated,
				DateModified = null
			};

			_context.Add<AuditTrail>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			return model;
		}

		#endregion Method(s)
	}
}