using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IWeeklyDatapointService
    {
        IQueryable<WeeklyDatapointViewModel> GetAll();

        void Save( WeeklyDatapointViewModel model );
     
    }
}
