using System;
using System.Linq;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class StaffSegmentService : IStaffSegmentService
	{
		private readonly IWFMPCPContext _context;

		public StaffSegmentService(IWFMPCPContext context)
		{
			this._context = context;
		}

		public IQueryable<StaffSegmentViewModel> GetAll()
		{
			var data = _context.AsQueryable<Data.Entities.StaffSegment>()
				.Select(x => new StaffSegmentViewModel()
				{
					ID = x.ID,
					SegmentCategoryID = (int)x.SegmentCategoryID,
					Name = x.Name,
					SortOrder = x.SortOrder,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,
					Visible = x.Visible
				}).AsQueryable();

			return data;
		}

		public IQueryable<StaffSegmentViewModel> GetAll(bool? active, bool? visible)
		{
			return this.GetAll().Where(x => ((x.Active == active) || (active == null)) && ((x.Visible == visible) || (visible == null))).AsQueryable();
		}

		public StaffSegmentViewModel GetByID(long id)
		{
			return this.GetByID(id, null, null);
		}

		public StaffSegmentViewModel GetByID(long id, bool? active, bool? visible)
		{
			return this.GetAll(active, visible).Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<Data.Entities.StaffSegment>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.StaffSegment>(data);
			_context.SaveChanges();
		}

		public void Hide(long id, string ntLogin)
		{
			this.HideShow(id, false, ntLogin);
		}

		public void Show(long id, string ntLogin)
		{
			this.HideShow(id, true, ntLogin);
		}

		public void Update(StaffSegmentViewModel model)
		{
			var data = _context.AsQueryable<Data.Entities.StaffSegment>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if lob already exists
			if (data.Name != model.Name || data.SegmentCategoryID != model.SegmentCategoryID)
			{
				var dataExists = _context.AsQueryable<Data.Entities.StaffSegment>().Where(x => x.Name == model.Name && x.SegmentCategoryID == model.SegmentCategoryID && x.Active == true).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("Segment name already exists in Segment Category.");
			}

			data.Name = model.Name ?? data.Name;
			data.SegmentCategoryID = model.SegmentCategoryID;
			data.SortOrder = model.SortOrder ?? data.SortOrder;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active ?? data.Active;
			data.Visible = model.Visible ?? data.Visible;

			_context.Update<Data.Entities.StaffSegment>(data);
			_context.SaveChanges();
		}

		public StaffSegmentViewModel Create(StaffSegmentViewModel model)
		{
			var dataExists = _context.AsQueryable<Data.Entities.StaffSegment>().Where(x => x.Name == model.Name && x.Active == true && x.SegmentCategoryID == model.SegmentCategoryID).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Segment name already exists in segment category.");

			var sortOrder = 0;
			var lastData = _context.AsQueryable<Data.Entities.StaffSegment>().Where(x => x.Active == true && x.SegmentCategoryID == model.SegmentCategoryID).OrderByDescending(x => x.SortOrder).FirstOrDefault();
			if (lastData != null)
				sortOrder = lastData.SortOrder + 1;

			var data = new Data.Entities.StaffSegment()
			{
				Name = model.Name,
				SegmentCategoryID = model.SegmentCategoryID,
				SortOrder = sortOrder,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated ?? DateTime.Now,
				DateModified = null,
				Active = model.Active ?? true,
				Visible = model.Visible ?? true
			};

			_context.Add<Data.Entities.StaffSegment>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			model.Active = data.Active;
			model.Visible = data.Visible;
			return model;
		}

		private void HideShow(long id, bool visible, string ntLogin)
		{
			var data = _context.AsQueryable<Data.Entities.StaffSegment>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Visible = visible;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.StaffSegment>(data);
			_context.SaveChanges();
		}
	}
}