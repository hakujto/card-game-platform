package cards_project.players.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CraftingRecipeControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"craftingrecipe_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CraftingRecipeController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/crafting_recipes")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CraftingRecipeController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/crafting_recipes")
        .withJsonBody(Json.parse("""{"dust_cost": 1, "is_available": true, "result_card_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CraftingRecipeController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/crafting_recipes/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

}
