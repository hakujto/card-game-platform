package cards_project.tournaments.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class SeasonControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"season_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "SeasonController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/seasons")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "SeasonController" should {
    "return 200 for search" in {
      val request = FakeRequest(GET, "/api/seasons?q=test")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "SeasonController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/seasons")
        .withJsonBody(Json.parse("""{"name": "test", "start_date": "2024-01-01", "end_date": "2024-12-31", "format": "STANDARD", "is_active": true}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "SeasonController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/seasons/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
