using System;

namespace CityRide.Database.Models
{
    public class UserCreateModel
    {
        public string First_name { get; set; }

        public string Last_name { get; set; }

        public string Email { get; set; }

        public string Cnp { get; set; }

        public string Address { get; set; }

        public string Password { get; set; }

        public string CARD_NUMBER { get; set; }

        public DateTime EXPIRATION_DATE { get; set; }

        public int CVV { get; set; }
    }
}