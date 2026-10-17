package cards_project.tournaments.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class TournamentControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"tournament_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "TournamentController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/tournaments")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TournamentController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/tournaments?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "TournamentController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/tournaments")
        .withJsonBody(Json.parse("""{"public_id": "00000000-0000-0000-0000-000000000001", "name": "Test Tournament Alpha", "format": "STANDARD", "tournament_type": "SWISS", "max_players": 8, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": true, "season_id": 1, "organizer_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "TournamentController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/tournaments/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
