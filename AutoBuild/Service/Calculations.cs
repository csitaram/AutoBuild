using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AutoBuild.Service
{
    public static class Calculations
    {
        public const string NegativeNumberException = "Value cannot be negative";
        public static int CalculateSum(int value1, int value2)
        {
            int sumValue = 0;
            if (value1 < 0 )
            {
                throw new FormatException(String.Format("Value1 {0} , {1}", value1, NegativeNumberException));
            }
            if (value2 < 0)
            {
                throw new FormatException(String.Format("Value2 {0} , {1}", value2, NegativeNumberException));
            }

            sumValue = value1 + value2;
            return sumValue;
        }
    }
}