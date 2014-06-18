import AssemblyKeys._

assemblySettings

organization          := "fr.lifl.emeraude"

name                  := "n2s3"

version               := "0.5.0"

scalaVersion          := "2.11.1"

jarName in assembly   := "bouya_test.jar"

///choisir son bouya_main ^^
//mainClass in assembly := Some("")

scalacOptions         := Seq("-unchecked", "-deprecation", "-encoding", "utf8")

resolvers ++= Seq(
  "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"
)

libraryDependencies ++= {
  val akkaV = "2.3.3"
  val scalatestV = "2.2.0"
  Seq(
    "com.typesafe.akka" %% "akka-actor"      % akkaV,
    "com.typesafe.akka" %% "akka-testkit"    % akkaV
   // "org.scalatest"     %% "scalatest"       % scalatestV % "test"
  )
}

testOptions += Tests.Argument(TestFrameworks.JUnit, "-v")

// cleanFiles <+= baseDirectory {
//   base => base / "project/project"
// }
