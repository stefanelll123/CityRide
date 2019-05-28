using CityRide.Database.Models;
using CityRide.Database.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace CityRide.WebAPi.Controllers
{
    [Route("api/authentification")]
    public class AuthentificationController : Controller
    {
        private readonly UserRepository _usereRepository;

        public AuthentificationController()
        {
            _usereRepository = new UserRepository();
        }

        [Route("users")]
        [HttpGet]
        public IActionResult GetUser(int userId)
        {
            var users =_usereRepository.GetUser(userId);

            return Ok(users);
        }

        [Route("register")]
        [HttpPost]
        public IActionResult CreateUser([FromBody] UserCreateModel userCreateModel)
        {
            var result = _usereRepository.CreateUser(userCreateModel);
            if (result == true)
            {
                return StatusCode(201);
            }

            return StatusCode(400);
        }

        [Route("login")]
        [HttpPost]
        public IActionResult Login([FromBody] LoginModel loginModel)
        {
            var result = _usereRepository.Login(loginModel);
            if (result == -1)
            {
                return NotFound();
            }

            return Ok(Json(result));
        }
    }
}
