package cards_project.players.model

import kotlinx.serialization.Serializable
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.like
import org.jetbrains.exposed.sql.javatime.CurrentDateTime
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.datetime
import org.jetbrains.exposed.sql.transactions.transaction

import cards_project.players.model.PlayerTable
import cards_project.tournaments.model.*

enum class PlayerSeasonStatsHighestRankType {
    BRONZE, SILVER, GOLD, PLATINUM, DIAMOND, MASTER, GRANDMASTER
}

object PlayerSeasonStatsTable : IntIdTable("player_season_stats") {
    val wins = integer("wins").default(0)
    val losses = integer("losses").default(0)
    val draws = integer("draws").default(0)
    val tournamentWins = integer("tournament_wins").default(0)
    val highestRank = enumerationByName<PlayerSeasonStatsHighestRankType>("highest_rank", 50).nullable()
    val seasonPoints = integer("season_points").default(0)
    val playerId = reference("player_id", PlayerTable, onDelete = ReferenceOption.CASCADE)
    val seasonId = reference("season_id", SeasonTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = datetime("created_at").defaultExpression(CurrentDateTime)
    val updatedAt = datetime("updated_at").defaultExpression(CurrentDateTime)
}

data class PlayerSeasonStatsRequest(
    val wins: Int,
    val losses: Int,
    val draws: Int,
    val tournamentWins: Int,
    val highestRank: PlayerSeasonStatsHighestRankType? = null,
    val seasonPoints: Int,
    val playerId: Int,
    val seasonId: Int
)

data class PlayerSeasonStatsResponse(
    val id: Int,
    val wins: Int,
    val losses: Int,
    val draws: Int,
    val tournamentWins: Int,
    val highestRank: PlayerSeasonStatsHighestRankType? = null,
    val seasonPoints: Int,
    val playerId: Int,
    val seasonId: Int,
    val createdAt: String,
    val updatedAt: String
)

fun ResultRow.toPlayerSeasonStatsResponse() = PlayerSeasonStatsResponse(
    id = this[PlayerSeasonStatsTable.id].value,
    wins = this[PlayerSeasonStatsTable.wins],
    losses = this[PlayerSeasonStatsTable.losses],
    draws = this[PlayerSeasonStatsTable.draws],
    tournamentWins = this[PlayerSeasonStatsTable.tournamentWins],
    highestRank = this[PlayerSeasonStatsTable.highestRank],
    seasonPoints = this[PlayerSeasonStatsTable.seasonPoints],
    playerId = this[PlayerSeasonStatsTable.playerId].value,
    seasonId = this[PlayerSeasonStatsTable.seasonId].value,
    createdAt = this[PlayerSeasonStatsTable.createdAt].toString(),
    updatedAt = this[PlayerSeasonStatsTable.updatedAt].toString()
)

object PlayerSeasonStatsRepository {

    fun list(skip: Int = 0, limit: Int = 100, q: String? = null): List<PlayerSeasonStatsResponse> = transaction {
        PlayerSeasonStatsTable.selectAll().limit(limit).offset(skip.toLong()).map { it.toPlayerSeasonStatsResponse() }
    }

    fun findById(id: Int): PlayerSeasonStatsResponse? = transaction {
        PlayerSeasonStatsTable.selectAll().where { PlayerSeasonStatsTable.id eq id }.singleOrNull()?.toPlayerSeasonStatsResponse()
    }

}
