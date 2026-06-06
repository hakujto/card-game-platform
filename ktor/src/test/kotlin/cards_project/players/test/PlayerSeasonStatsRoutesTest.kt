package cards_project.players.test

import cards_project.players.model.*
import cards_project.players.routes.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.server.routing.*
import io.ktor.server.testing.*
import kotlinx.serialization.json.*
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import cards_project.plugins.configureTestDb
import cards_project.plugins.configureSerialization

class PlayerSeasonStatsRoutesTest {

    private fun testApp(block: suspend ApplicationTestBuilder.() -> Unit) = testApplication {
        application {
            configureTestDb()
            configureSerialization()
            routing { playerSeasonStatsRoutes() }
        }
        block()
    }

    @Test fun `list returns 200`() = testApp {
        val r = client.get("/api/player_season_statses")
        assertEquals(HttpStatusCode.OK, r.status)
    }

    @Test fun `get not found returns 404`() = testApp {
        val r = client.get("/api/player_season_statses/99999")
        assertEquals(HttpStatusCode.NotFound, r.status)
    }

}
