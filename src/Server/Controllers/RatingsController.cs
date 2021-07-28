using Microsoft.AspNetCore.Mvc;
using Ratings.Server.Context;
using Ratings.Shared;
using System.Collections.Generic;

namespace Ratings.Server.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RatingsController : ControllerBase
    {
        private readonly IRatingRepo _repo;

        public RatingsController(IRatingRepo repo)
        {
            _repo = repo;
        }

        [HttpGet]
        public ActionResult<IEnumerable<RatingModel>> GetRatingModels()
        {
            return _repo.GetRatings();
        }

        [HttpGet("{id}")]
        public ActionResult<RatingModel> GetRatingModel(string id)
        {
            var ratingModel = _repo.GetRating(id);

            if (ratingModel == null)
            {
                return NotFound();
            }

            return ratingModel;
        }

        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public ActionResult<RatingModel> PostRatingModel(RatingModel ratings)
        {
            try
            {
                _repo.AddRating(ratings);
            }
            catch (AddRatingException)
            {
                return NoContent();
            }
            catch (System.ArgumentException)
            {
                if (_repo.Exists(ratings.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction(nameof(this.GetRatingModel), new { id = ratings.Id }, ratings);
        }
    }
}
