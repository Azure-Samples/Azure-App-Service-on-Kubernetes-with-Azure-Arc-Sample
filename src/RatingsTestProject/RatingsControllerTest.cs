using Xunit;
using Moq;
using Ratings.Shared;
using System.Collections.Generic;
using Ratings.Server.Controllers;
using Ratings.Server.Context;
using Microsoft.AspNetCore.Mvc;
using Ratings.Server;

namespace RatingsTestProject
{
    public class RatingsControllerTest
    {
        [Fact]
        public void GetRatingModels_ReturnsAllRatings()
        {
            // Arrange
            var mockRepo = new Mock<IRatingRepo>();
            List<RatingModel> expectedRatingsList = new List<RatingModel>();
            expectedRatingsList.Add(new RatingModel("book", 1, "read"));
            expectedRatingsList.Add(new RatingModel("text", 2, "read"));
            mockRepo.Setup(x => x.GetRatings()).Returns(expectedRatingsList);

            var controller = new RatingsController(mockRepo.Object);

            // Act
            var result = controller.GetRatingModels();

            // Assert
            Assert.Equal(expectedRatingsList, result.Value);
        }

        [Fact]
        public void GetRatingModel_RatingIdExists()
        {
            // Arrange
            string id = "ice_cream1";
            RatingModel expectedRating = new RatingModel("ice_cream1", 5, "Great ice cream flavour!");
            var mockRepo = new Mock<IRatingRepo>();
            mockRepo.Setup(x => x.GetRating(id)).Returns(expectedRating);
            var controller = new RatingsController(mockRepo.Object);

            // Act
            var result = controller.GetRatingModel(id);

            // Assert
            Assert.Equal(expectedRating, result.Value);
        }

        [Fact]
        public void GetRatingModel_RatingIdDoesNotExist()
        {
            // Arrange
            string id = "ice_cream1";
            var mockRepo = new Mock<IRatingRepo>();
            mockRepo.Setup(x => x.GetRating(id)).Returns((RatingModel)null);
            var controller = new RatingsController(mockRepo.Object);

            // Act
            var result = controller.GetRatingModel(id);

            // Assert
            Assert.Equal((new NotFoundResult()).ToString(), result.Result.ToString());
        }

        [Fact]
        public void PostRatingModel_RatingWasPosted()
        {
            // Arrange
            RatingModel expectedRatingToPost = new RatingModel("ice_cream2", 10, "The best!");
            var mockRepo = new Mock<IRatingRepo>();
            var controller = new RatingsController(mockRepo.Object);

            // Act
            var result = controller.PostRatingModel(expectedRatingToPost);

            // Assert
            mockRepo.Verify(m => m.AddRating(expectedRatingToPost), Times.Once);
        }

        [Fact]
        public void PostRatingModel_RatingWasNotPosted_NoContentResult()
        {
            // Arrange
            RatingModel expectedRatingToPost = new RatingModel(null, 0, null);
            var mockRepo = new Mock<IRatingRepo>();
            mockRepo.Setup(x => x.AddRating(expectedRatingToPost)).Throws(new AddRatingException("Invalid input id"));
            var controller = new RatingsController(mockRepo.Object);

            // Act
            var result = controller.PostRatingModel(expectedRatingToPost);

            // Assert
            Assert.IsType<NoContentResult>(result.Result);
        }

        [Fact]
        public void PostRatingModel_RatingWasNotPosted_ConflictResult()
        {
            // Arrange
            RatingModel expectedRatingToPost = new RatingModel("book", 12, "nice read");
            var mockRepo = new Mock<IRatingRepo>();
            mockRepo.Setup(x => x.AddRating(expectedRatingToPost)).Throws(new System.ArgumentException());
            mockRepo.Setup(x => x.Exists(expectedRatingToPost.Id)).Returns(true);
            var controller = new RatingsController(mockRepo.Object);

            // Act
            var result = controller.PostRatingModel(expectedRatingToPost);

            // Assert
            Assert.IsType<ConflictResult>(result.Result);
        }
    }
}
