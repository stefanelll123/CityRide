using System;

namespace CityRide.Database.Models
{
    public class IssueModel
    {
        public DateTime Registration_date { get; set; }

        public string Description { get; set; }

        public string Severity { get; set; }

        public int Borrow_id { get; set; }

        public string Type_issue { get; set; }

        public int Bicycle_id { get; set; }

        public string Status { get; set; }
    }
}