/***
* Name: immigration
* Author: admin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Immigration

/* Insert your model definition here */

global{
	float step <- 1 #month;
	float temps <- 0;
	int dureMandat <- 0;
	list<string> DEFAULT_REGIME <- [ "COURT", "LONG"];
	int aideEntreprenariat <- rnd(10);
	int gestionRessource <- rnd(10);
	
}


species gouvernement{
	int gestion_ressource;
	string regime;
	int aide_entreprenariat;
	int duree_regime; 
	
	reflex choix_politique when: temps=60{
		if (duree_regime = 5){
			ask pays_nord{
				if (impact_election){
					myself.gestion_ressource <- 10 - exploitation_ressources;
					myself.aide_entreprenariat <- rnd(10);
				}else{
					myself.gestion_ressource <- rnd(10);
					myself.aide_entreprenariat <- rnd(10);
				}
			}
		}else{
			//a completer
		}
	}
	reflex update_time{
		temps <- temps +1 ;
		if (temps = 61){
			temps <-0;
		}
	}
	reflex creer_emploi{
		
	}
}

species individues{
	int niveau_alphabetisation;
	bool est_entrepreneur;
	bool a_une_entreprise;
	int revenue;
	int compte;
	bool estChomeur;
	int age;
	int niveau_sensibilisation;
	reflex trouver_travail{
		
	}
		reflex augmenter_compte{
		
	}
	reflex creation_entreprise when:est_entrepreneur and !a_une_entreprise{
	
	}
	reflex immigrer{
		
	}
	
}

species societe_civile{
	int sensibilisation;
	
	
}

species pays_nord{
	int exploitation_ressources;
	int politique_immigration;
	bool impact_election;
    int richesse;
    
    reflex s_enrichir{
    	
    }
    reflex election when: temps=60{
    	exploitation_ressources <- rnd(10);
    	politique_immigration <- rnd(10);
    	impact_election <- rnd(0,1);	
    }


}



species pays_sud{
	gouvernement gouv;
	individues population;
	float croissance_demographique;
	float pib;
	float croissance_pib;
	float taux_alphabetisation;
	societe_civile sc;
	int nbr_entrepreneurs;
	int nbr_emigres;
	int nbr_tentatives_depart;
	int nbr_chomeurs;
	int pourcentage_alphabetise;
	
	
	
}


experiment exec {	
	
	// Define parameters to explore here if necessary
	// parameter "My parameter" category: "My parameters" var: one_global_attribute;
	// Define a method of exploration
	// method exhaustive minimize: one_expression;
	// Define attributes, actions, a init section and behaviors if necessary
	// init { }

}