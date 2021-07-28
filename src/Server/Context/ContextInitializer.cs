using Ratings.Shared;

namespace Ratings.Server.Context
{
    internal class ContextInitializer : IContextInitialiser
    {
        bool ratingContextInitialised = false;

        public void Initialise(RatingContext ratingContext)
        {
            if (ratingContextInitialised) return;

            RatingModel rating = CreateModel("book", 12, "nice read");
            ratingContext.AddRating(rating);

            rating = CreateModel("phone", 30, "modern design");
            ratingContext.AddRating(rating);

            rating = CreateModel("bike", 100, "nice ride");
            ratingContext.AddRating(rating);

            ratingContextInitialised = true;
        }

        private static RatingModel CreateModel(string id, int rating, string userNotes)
        {
            RatingModel model = new RatingModel(id, rating, userNotes);
            return model;
        }
    }
}
