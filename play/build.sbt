name := "cards_project"
organization := "cards_project"
version := "1.0.0"

scalaVersion := "3.3.4"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

libraryDependencies ++= Seq(
  guice,
  evolutions,
  "com.typesafe.slick"  %% "slick"            % "3.5.2",
  "org.playframework"   %% "play-slick"        % "6.1.1",
  "org.playframework"   %% "play-slick-evolutions" % "6.1.1",
  "com.h2database"       % "h2"               % "2.3.232",
  "org.xerial"           % "sqlite-jdbc"      % "3.46.1.3",
  "org.scalatestplus.play" %% "scalatestplus-play" % "7.0.1" % Test,
)

// Avoids RUNNING_PID issues in containers
javaOptions in Universal += "-Dpidfile.path=/dev/null"

scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
)
