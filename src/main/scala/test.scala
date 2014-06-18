object Test extends App{

  val x = Seq(1,3,2)
  val sn = Seq(1,2,3,4,5,6)

  def f= {
    var r = 0
    for (i<-1 until x.length) {
      r = r+(x(i-1)* x(i))
    }
    r
  }


  println(f)

  def bouya={
    var n1=0
    var n2=1
    var couche=1
    var nbneu=x(couche)
    for ( i<-0 until f ){

      println("S = "+n1+"_"+n2+" nb="+i+" couche="+couche+" nbneu="+nbneu+" i="+i)

      if ( n2 >= nbneu ){
        if( i == x(couche-1) ){
          nbneu=nbneu+(couche+1)
          couche=couche+1
          n1=n1+1

          n2=n2+1
        }
        else{
          // rec=rec+x(couche)
          n1=n1+1
          n2=n2-x(couche)+1

        }
      }
      else {
        n2=n2+1
      }
    }
  }
  bouya
}

