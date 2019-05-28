using CityRide.Database.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace CityRide.WebAPi.Controllers
{
    [Route("api/admin")]
    public class AdminController : ControllerBase
    {
        private StatisticRepository _statisticRepository;

        public AdminController()
        {
            _statisticRepository = new StatisticRepository();
        }

        [Route("issues")]
        [HttpGet]
        public IActionResult GetAllIssues()
        {
            var result = _statisticRepository.GetAllIssues();

            return Ok(result);
        }

        [Route("bicycles")]
        [HttpGet]
        public IActionResult GetAllBicycles()
        {
            var result = _statisticRepository.GetAllBicycle();

            return Ok(result);
        }

        [Route("bicycles/broken")]
        [HttpGet]
        public IActionResult GetAllBrokenBicycles()
        {
            var result = _statisticRepository.GetAllBicycleByStatus("broken");

            return Ok(result);
        }

        [Route("bicycles/available")]
        [HttpGet]
        public IActionResult GetAllAvailableBicycles()
        {
            var result = _statisticRepository.GetAllBicycleByStatus("available");

            return Ok(result);
        }

        [Route("bicycles/borrowed")]
        [HttpGet]
        public IActionResult GetAllBorrowedBicycles()
        {
            var result = _statisticRepository.GetAllBicycleByStatus("borrowed");

            return Ok(result);
        }
    }
}
