using Microsoft.EntityFrameworkCore;
using Ratings.Shared;
using System.Collections.Generic;
using System.Linq;

namespace Ratings.Server.Context
{
    public class RatingContext : DbContext, IRatingRepo
    {

        private DbSet<RatingModel> ratings { get; set; }

        public RatingContext(DbContextOptions<RatingContext> options, IContextInitialiser initialiser)
            : base(options)
        {
            initialiser.Initialise(this);
        }

        public void AddRating(RatingModel rating)
        {
            if (string.IsNullOrWhiteSpace(rating.Id))
                throw new AddRatingException("Invalid input id");

            ratings.Add(rating);
            SaveChanges();
        }

        public List<RatingModel> GetRatings()
        {
            return ratings.ToList();
        }

        public RatingModel GetRating(string id)
        {
            return ratings.Find(id);
        }

        public bool Exists(string id)
        {
            return ratings.Any(r => r.Id == id);
        }
    }
}
