using CityRide.Database.Models;
using CityRide.Database.Repositories;
using Microsoft.AspNetCore.Mvc;

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
    }
}
