object f {

  println("Welcome to the Scala worksheet")       //> Welcome to the Scala worksheet
  val nums = List(1.0, 2.0, 3.0, 4.0)             //> nums  : List[Double] = List(1.0, 2.0, 3.0, 4.0)
  // nums: List[Int] = List(1, 2, 3, 4)

  val sum = nums.foldRight(0.0) {
    (acc, num) => acc + num
  }                                               //> sum  : Double = 10.0
  val sup = nums.foldLeft(0.0)((i, s) => i max s) //> sup  : Double = 4.0
  //sum: Int = 10
  lazy val lines: List[String] = io.Source.fromFile("fr.dic").getLines.toList
                                                  //> lines: => List[String]

  lazy val words = lines.map(_.split("/")(0))     //> words: => List[String]

  lazy val truePalindromes = words filter (w => w == w.reverse)
                                                  //> truePalindromes: => List[String]
  val longest = words.foldLeft("")((i, s) =>
    if (i.length > s.length) i
    else s)                                       //> longest  : String = Mecklembourg-Poméranie-Occidentale	26
  /*list.foldLeft(b0)(f)
(b0 /: list)(f)*/
  val longest2 = ("" /: words)((i, s) =>
    if (i.length > s.length) i
    else s)                                       //> longest2  : String = Mecklembourg-Poméranie-Occidentale	26
  val longest3 = (words :\ "")((i, s) =>
    if (i.length > s.length) i
    else s)                                       //> longest3  : String = Mecklembourg-Poméranie-Occidentale	26
 
 
  val long2 = words.foldLeft((0, ""))((i, s) =>
    if (i._1 < s.length) (s.length, s)
    else i)                                       //> long2  : (Int, String) = (37,Mecklembourg-Poméranie-Occidentale	26)


  val long3 = words.reduceLeft((s1, s2) =>
    if (s2.length > s1.length) s2
    else s1)                                      //> long3  : String = Mecklembourg-Poméranie-Occidentale	26

}