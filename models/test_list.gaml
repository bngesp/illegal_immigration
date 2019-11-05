/***
* Name: testlist
* Author: admin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model testlist

/* Insert your model definition here */

global{
	
	list<test> l;
	int nbr_mort <- 0;
	
	init{
		create test number:4;
		l<-test;
	}
	
	reflex time_to_dead {
		
		write "cycle = "+cycle;
		write "la taille de la liste  avant la mort: " +length(l);
		l<-test;
		write "la taille de la liste  apres la mort: " +length(l);
		write "nombre de mort " +nbr_mort;
		write "\n";
		
	}
}

species test{
	int taux <- rnd(10);
	reflex time_to_dead when:taux > 5{
		write "ohh je meurs";
		nbr_mort<- nbr_mort +1;
		do die;
	}
	
	reflex vieillir{
		taux<-rnd(14);
		create test number:1;
	}
}


experiment exec {	


}