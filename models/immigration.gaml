/***
* Name: immigration
* Author: admin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model immigration

/* Insert your model definition here */

global{
	
}


species gouvernement{
	int gestion_ressource;
	string regime;
	int aide_entreprenariat;
	int duree_regime;
	
}

species individues{
	int niveau_alphabetisation;
	int entreprenariat;
	int revenue;
	bool estChomeur;
	int age;
	int niveau_sensibilisation;
	
}

species societe_civile{
	int sensibilisation;
	
	
}

species pays_nord{
	int exploitation_ressources;
	string politique_immigration;
	bool impact_processus;
}



species pays_sud{
	gouvernement gouv;
	individues pop;
	societe_civile sc;
	
	
}


experiment exec {	
	
	// Define parameters to explore here if necessary
	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
	// Define a method of exploration
	// method exhaustive minimize: one_expression;
	// Define attributes, actions, a init section and behaviors if necessary
	// init { }

}