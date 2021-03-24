using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Infrastructure.Extensions
{
    public static class StringExtensions
    {
        public static int ToInt32(this string val)
        {
            return Convert.ToInt32( val );
        }
    }
}
