class test(filename: String = "fr.dic") {

  //class Reader(filename: String = "/usr/share/hunspell/fr.dic") { //val word:GenSeq[String]){
    val lines: List[String] = io.Source.fromFile(filename).getLines.toList
    
    val words = lines.map(_.split("/")(0))
    lazy val truePalindromes = words filter (w => w == w.reverse)

    /* def replaceFromMap(s:String,remplacement:Map[String,Char])={
      val explodeRepl = (for(s<-replacements.key; c<-k)
        yield(c -> replacements(k)).toMap)
        s map(c => explodeRepl.get(c).getOrElse(c))
      
  
    
    }
    
    def removeDiacritics(s:String)=replaceFromMap(s, Map("àâ"->'a'))
    
    lazy val palimdromes =for (w <-words;
    
    				wl =removeDiacritics(w.toLowerCase)
      
  }
  
*/
  }