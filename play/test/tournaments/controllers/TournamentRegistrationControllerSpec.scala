package cards_project.tournaments.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class TournamentRegistrationControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"tournamentregistration_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "TournamentRegistrationController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/tournament_registrations")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TournamentRegistrationController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/tournament_registrations")
        .withJsonBody(Json.parse("""{"status": "REGISTERED", "points_earned": 1, "registered_at": "2024-01-01T00:00:00", "tournament_id": 1, "player_id": 1, "deck_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "TournamentRegistrationController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/tournament_registrations/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
