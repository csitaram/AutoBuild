using System;
using Xunit;
using AutoBuild.Service;

namespace AutoBuild.Tests
{
     public class UnitTest1
    {
        
        [Fact]
        public void CalculateSum_WhenValuesAreNegative_ShouldThrowException()
        {
            int value1 = -1;
            int value2 = -1;

            Assert.Throws<FormatException>(() => Calculations.CalculateSum(value1, value2));
      }
     
        [Fact]
        public void CalculateSum_ShouldReturnSumOfValues()
        {
            int value1 = 10;
            int value2 = 11;

            int sumValue= Calculations.CalculateSum(value1, value2);

            Assert.Equal(21, sumValue);
        }
    }
}
