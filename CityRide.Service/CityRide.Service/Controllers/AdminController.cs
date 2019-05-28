using System.Linq;
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

            return Ok(result.Take(1000));
        }

        [Route("bicycles/available")]
        [HttpGet]
        public IActionResult GetAllAvailableBicycles()
        {
            var result = _statisticRepository.GetAllBicycleByStatus("available");

            return Ok(result.Take(1000));
        }

        [Route("bicycles/borrowed")]
        [HttpGet]
        public IActionResult GetAllBorrowedBicycles()
        {
            var result = _statisticRepository.GetAllBicycleByStatus("borrowed");

            return Ok(result.Take(1000));
        }

        [Route("bicycles/load_old")]
        [HttpPost]
        public IActionResult FindOldBicycles()
        {
            var result = _statisticRepository.FindOldBicycles();
            if (result)
            {
                return StatusCode(200);
            }

            return NotFound();
        }

        [Route("bicycles/load_old")]
        [HttpGet]
        public IActionResult GetOldBicycles()
        {
            var result = _statisticRepository.GetOldBicyclesIssues();
            
            return Ok(result);
        }

        [Route("bicycles/load_maintainance")]
        [HttpPost]
        public IActionResult FindMaintainanceBicycles()
        {
            var result = _statisticRepository.FindMaintananceBicycles();
            if (result)
            {
                return StatusCode(200);
            }

            return NotFound();
        }

        [Route("bicycles/load_maintainance")]
        [HttpGet]
        public IActionResult GetMaintainanceBicycles()
        {
            var result = _statisticRepository.GetMaintananceBicyclesIssues();
            
            return Ok(result);
        }

        [Route("bicycles/overdue")]
        [HttpGet]
        public IActionResult GetOverdueBicycles()
        {
            var result = _statisticRepository.GetOverdueBicyclesIssues();
            
            return Ok(result);
        }

        [Route("bicycles/issues")]
        [HttpGet]
        public IActionResult GetOverdueBicycles(int bicycleId)
        {
            var result = _statisticRepository.GetBicyclesIssues(bicycleId);
            
            return Ok(result);
        }
    }
}
