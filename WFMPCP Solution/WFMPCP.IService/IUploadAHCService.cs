using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.IService
{
    public interface IUploadAHCService
    {
        bool ExcelRead( string fileName, string column, int columns );

		bool ExtractCSV(string filelocation, string ntLogin);
    }
}
