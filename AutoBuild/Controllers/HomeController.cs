using AutoBuild.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AutoBuild.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
       
        public ActionResult CalculateSum(FormCollection form)
        {
            int value1 = int.Parse(form["Value1"]);
            int value2 = int.Parse(form["Value2"]);


            int sumValue = Calculations.CalculateSum(value1, value2);

            ViewBag.SumValue = sumValue;

            return View("Index");
        }
    }
}