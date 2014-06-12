//import AssemblyKeys._

//assemblySettings

//organization          := ""

name                  := "Tests"

version               := "0.1"

scalaVersion          := "2.10.3"

//jarName in assembly   := "test.jar"

//mainClass in assembly := Some("fr.lifl.emeraude.n2s3.Main")

scalacOptions         := Seq("-unchecked", "-deprecation", "-encoding", "utf8")

resolvers ++= Seq(
  "Spray Repo" at "http://repo.spray.io/",
  "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/",
  "spray" at "http://repo.spray.io"
)

libraryDependencies ++= {
  val sprayV = "1.3.1"
  val akkaV = "2.3.0"
  Seq(
    "com.typesafe.akka" %% "akka-actor"      % "2.2.1",
    "com.typesafe.akka" %% "akka-testkit"    % "2.2.1" ,
    "org.scalatest"     %% "scalatest"       % "1.9.1" % "test"
   //"junit"              % "junit"           % "4.11"  % "test",
  //  "com.novocode"       % "junit-interface" % "0.10"  % "test"
  )
}

testOptions += Tests.Argument(TestFrameworks.JUnit, "-v")
// seq(Revolver.settings: _*)
