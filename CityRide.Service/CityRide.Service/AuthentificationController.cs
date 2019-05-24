using CityRide.Database.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace CityRide.WebAPi
{
    [Route("api/authentification")]
    public class AuthentificationController : Controller
    {
        private readonly UserRepository _usereRepository;

        public AuthentificationController()
        {
            _usereRepository = new UserRepository();
        }

        [HttpGet]
        public IActionResult Test()
        {
            var users =_usereRepository.GetUser(1);

            return Ok(users);
        }
    }
}
