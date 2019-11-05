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
	float temps <- 0.0;
	int dureMandat <- 0;
	int emploi_disponible <- 0;
	list<string> DEFAULT_REGIME <- [ "COURT", "LONG"];
	int aideEntreprenariat <- rnd(10);
	int gestionRessource <- rnd(10);
	init{
		
	}
	reflex update_time{
		temps <- temps +1 ;
		if (temps = 61){
			temps <- 0.0;
		}
	}
	
}


species gouvernement{
	int gestion_ressource;
	string regime;
	int aide_entreprenariat;
	int duree_regime; 
	int richesse_pays;
	
	
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
			ask pays_nord{
				if (impact_election){
					myself.gestion_ressource <- 10 - exploitation_ressources;
					myself.aide_entreprenariat <- rnd(10);
				}else{
					myself.gestion_ressource <- rnd(10);
					myself.aide_entreprenariat <- rnd(10);
				}
			}
		}
	}
	reflex creer_emploi{
		emploi_disponible<-emploi_disponible + ((gestion_ressource+1)*700);
	}
	reflex s_enrichir{
		richesse_pays <- richesse_pays + gestion_ressource*10000;
	}

	bool aide_creation_emploi{
		bool el <- false;
		if(aide_entreprenariat>5) {
			ask pays_sud{
			el<- self.estStable;
		}
	
	} return el;
}
	
	action changer_regime(int f){
		duree_regime <- f;
		regime <- (f>5)? DEFAULT_REGIME[0]:DEFAULT_REGIME[1];
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
	
	reflex trouver_travail when: estChomeur{
		if(emploi_disponible >0)
		{
			estChomeur <- false;
			revenue<-revenue + (niveau_alphabetisation*96000); 
			emploi_disponible <- emploi_disponible-1;
		}
	}
	reflex augmenter_compte{
		compte <- compte + revenue/10;
	}
	reflex creation_entreprise when:est_entrepreneur and !a_une_entreprise{
		if(compte>revenue*2){
			ask pays_sud{
				nbr_entrepreneurs <-nbr_entrepreneurs + 1;
				
			}
		}
	}
	reflex immigrer{
		//Condition d'immigration a définir indice défini par le revenue, niveau sensibilisation et politique immigration extérieur et chance de survie
	}
	
	bool can_work{
		return age<35 and age>15;
	}
	
	bool est_sensbiliser{
		return flip(niveau_sensibilisation/10) 
				or 
				(niveau_sensibilisation>5 and niveau_alphabetisation>5) 
				or 
				(flip(niveau_alphabetisation/10) and est_entrepreneur); 
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
    int richesse_pays;
    
    reflex s_enrichir{
    	richesse_pays <- richesse_pays + exploitation_ressources*10000;
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
	societe_civile sc;
	float croissance_demographique;
	float pib;
	float croissance_pib;
	float taux_alphabetisation;
	int nbr_entrepreneurs;
	int nbr_emigres;
	int nbr_tentatives_depart;
	int nbr_chomeurs;
	int pourcentage_alphabetise;
	bool estStable;
	
	
	
}


experiment exec {	


}