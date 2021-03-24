using System;
using System.Linq;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class SegmentCategoryService : ISegmentCategoryService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public SegmentCategoryService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<SegmentCategoryViewModel> GetAll()
		{
			var data = _context.AsQueryable<Data.Entities.SegmentCategory>()
				.Select(x => new SegmentCategoryViewModel()
				{
					ID = x.ID,
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

		public SegmentCategoryViewModel GetByID(int id)
		{
			return this.GetAll().Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(int id, string ntLogin)
		{
			var data = _context.AsQueryable<Data.Entities.SegmentCategory>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.SegmentCategory>(data);
			_context.SaveChanges();
		}

		public void Update(SegmentCategoryViewModel model)
		{
			var data = _context.AsQueryable<Data.Entities.SegmentCategory>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if lob already exists
			if (data.Name != model.Name)
			{
				var dataExists = _context.AsQueryable<Data.Entities.SegmentCategory>().Where(x => x.Name == model.Name).FirstOrDefault();
				if (dataExists != null)
					if (data.ID != dataExists.ID)
						throw new ArgumentException("Site name already exists.");
			}

			data.Name = model.Name ?? data.Name;
			data.SortOrder = model.SortOrder ?? data.SortOrder;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active ?? data.Active;
			data.Visible = model.Visible ?? data.Visible;

			_context.Update<Data.Entities.SegmentCategory>(data);
			_context.SaveChanges();
		}

		public SegmentCategoryViewModel Create(SegmentCategoryViewModel model)
		{
			var dataExists = _context.AsQueryable<Data.Entities.SegmentCategory>().Where(x => x.Name == model.Name && x.Active == true).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Segment Category name already exists in campaign.");

			var sortOrder = 0;
			var lastData = _context.AsQueryable<Data.Entities.SegmentCategory>().Where(x => x.Active == true).LastOrDefault();
			if (lastData != null)
				sortOrder = lastData.SortOrder + 1;

			var data = new Data.Entities.SegmentCategory()
			{
				Name = model.Name,
				SortOrder = sortOrder,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated ?? DateTime.Now,
				DateModified = null,
				Active = model.Active == null ? true : false,
				Visible = model.Visible == null ? true : false
			};

			_context.Add<Data.Entities.SegmentCategory>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			model.Active = data.Active;
			model.Visible = data.Visible;
			return model;
		}

		#endregion Method(s)
	}
}