package cards_project.tournaments.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class TournamentPrizeControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"tournamentprize_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "TournamentPrizeController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/tournament_prizes")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TournamentPrizeController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/tournament_prizes")
        .withJsonBody(Json.parse("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "TournamentPrizeController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/tournament_prizes/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "TournamentPrizeController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/tournament_prizes")
        .withJsonBody(Json.parse("""{"placement_from": 1, "placement_to": 1, "prize_type": "CURRENCY", "amount": 1.00, "season_points": 1, "tournament_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/tournament_prizes/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
