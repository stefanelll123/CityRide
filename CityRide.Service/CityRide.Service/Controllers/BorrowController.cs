using CityRide.Database.Models;
using CityRide.Database.Repositories;
using Microsoft.AspNetCore.Mvc;
using System;

namespace CityRide.WebAPi.Controllers
{
    [Route("api/borrow")]
    public class BorrowController : ControllerBase
    {
        private readonly BorrowRepository _borrowRepository;

        public BorrowController()
        {
            _borrowRepository = new BorrowRepository();
        }

        [HttpPost]
        public IActionResult BorrowBicycle([FromBody] BorrowModel borrowModel)
        {
            if (checkForSQLInjection(borrowModel.QrCode))
            {
                return BadRequest();
            }

            var result = _borrowRepository.BorrowBicycle(borrowModel);

            if (result == false)
            {
                return BadRequest();
            }

            return StatusCode(201);
        }


        [HttpGet]
        public IActionResult BicycleExists(int userId)
        {
            var exists = _borrowRepository.BicycleExists(userId);
            if (exists)
            {
                return StatusCode(200);
            }

            return NotFound();
        }

        [Route("return")]
        [HttpPost]
        public IActionResult ReturnBicycle([FromBody] ReturnModel returnModel)
        {
            var result = _borrowRepository.ReturnBicycle(returnModel);
            if (result == false)
            {
                return BadRequest();
            }

            return StatusCode(201);
        }

        [Route("price")]
        [HttpGet]
        public IActionResult GetBicycleBorrowPrice(int userId)
        {
            var price = _borrowRepository.GetBorrowPrice(userId);

            return Ok(price);
        }


        public static Boolean checkForSQLInjection(string userInput)
        {
            bool isSQLInjection = false;

            string[] sqlCheckList =
            {
                "--",
                ";--",
                ";",
                "/*",
                "*/",
                "@@",
                "@",
                "char",
                "nchar",
                "varchar",
                "nvarchar",
                "alter",
                "begin",
                "cast",
                "create",
                "cursor",
                "declare",
                "delete",
                "drop",
                "end",
                "exec",
                "execute",
                "fetch",
                "insert",
                "kill",
                "select",
                "sys",
                "sysobjects",
                "syscolumns",
                "table",
                "update"
            };

            string CheckString = userInput.Replace("'", "''");
            for (int i = 0; i <= sqlCheckList.Length - 1; i++)
            {
                if ((CheckString.IndexOf(sqlCheckList[i],
                         StringComparison.OrdinalIgnoreCase) >= 0))
                {
                    isSQLInjection = true;
                }
            }

            return isSQLInjection;
        }
    }
}

