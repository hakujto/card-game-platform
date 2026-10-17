package cards_project.players.controllers

import org.scalatestplus.play._
import org.scalatestplus.play.guice._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._

import play.api.inject.guice.GuiceApplicationBuilder

class CraftingIngredientControllerSpec extends PlaySpec with GuiceOneAppPerTest with Injecting {

  override def fakeApplication() = {
    val dbName = s"craftingingredient_test_${System.nanoTime()}"
    val url = s"jdbc:h2:mem:${dbName};MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1"
    new GuiceApplicationBuilder().configure(
      "slick.dbs.default.db.url" -> url
    ).build()
  }

  "CraftingIngredientController" should {
    "return 200 for list" in {
      val request = FakeRequest(GET, "/api/crafting_ingredients")
      val result  = route(app, request).get
      status(result) mustBe OK
    }
  }

  "CraftingIngredientController" should {
    "return 201 for create" in {
      val request = FakeRequest(POST, "/api/crafting_ingredients")
        .withJsonBody(Json.parse("""{"quantity": 1, "recipe_id": 1, "card_id": 1}"""))
      val result = route(app, request).get
      status(result) mustBe CREATED
    }
  }

  "CraftingIngredientController" should {
    "return 404 for not found" in {
      val request = FakeRequest(GET, "/api/crafting_ingredients/99999")
      val result  = route(app, request).get
      status(result) mustBe NOT_FOUND
    }
  }

  "CraftingIngredientController" should {
    "return 204 for delete" in {
      val createReq = FakeRequest(POST, "/api/crafting_ingredients")
        .withJsonBody(Json.parse("""{"quantity": 1, "recipe_id": 1, "card_id": 1}"""))
      val createResult = route(app, createReq).get
      val id = (contentAsJson(createResult) \ "id").as[Long]
      val deleteReq = FakeRequest(DELETE, s"/api/crafting_ingredients/$id")
      val deleteResult = route(app, deleteReq).get
      status(deleteResult) mustBe NO_CONTENT
    }
  }

}
