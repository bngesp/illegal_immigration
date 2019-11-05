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
	string regime;
	list<string> DEFAULT_REGIME <- [ "COURT", "LONG"];
	int aideEntreprenariat <- rnd(10);
	int gestionRessource <- rnd(10);
	init{
		create individues number:4;
		create pays_sud number:1{
			population <- individues;
		}
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
	int annee_ecoule<- 0;
	
	reflex update_annee{ annee_ecoule <-  (temps div duree_regime = 0 ) ? 0 : annee_ecoule+1;}
	
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
	
	action augmente_sensibilisation(int a){
		niveau_sensibilisation <- (niveau_sensibilisation + a ) div 10 ;
	}
	
}

species societe_civile{
	int sensibilisation;
	
	reflex sensibiliser when:temps=60{
		sensibilisation <- rnd(10);
	}
	
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
	list<individues> population;
	societe_civile sc;
	float croissance_demographique;
	float pib;
	float croissance_pib;
	float taux_alphabetisation;
	int nbr_entrepreneurs;
	int nbr_emigres;
	int nbr_tentatives_depart;
	int nbr_chomeurs;
	bool estStable;
	float taux_sensibilisation;
	int nbr_hbt_a_sensibiliser <- 0;
	
	
	
	reflex sensibiliser{
		//int impact_sensbilisation;
		int nbr_hbt <- length(population);
		
		if( (temps div gouv.duree_regime)=0){
			nbr_hbt_a_sensibiliser<- int(nbr_hbt*taux_sensibilisation/100);
		}
		if(nbr_hbt_a_sensibiliser != 0 ){
			int nbr_hbt_a_sensibiliser_par_mois <- int(nbr_hbt_a_sensibiliser/gouv.duree_regime);
			int index <- nbr_hbt_a_sensibiliser_par_mois*gouv.annee_ecoule;
			if(index +nbr_hbt_a_sensibiliser_par_mois > nbr_hbt-1) {
				write "tout le pays est sensibilise";
			}
			else{
				loop vrr from:index to: index+nbr_hbt_a_sensibiliser_par_mois{ 
					 population[vrr].niveau_sensibilisation <- (population[vrr].niveau_sensibilisation + sc.sensibilisation ) div 10 ;
				}
			}
			
		}
	}
	
	reflex update_population when:(temps div 12)=0 {
		int peuple <- length(individues);
		int augmentation <- int(peuple + peuple*(croissance_demographique/100));
		create individues number:augmentation;
		population <- list(individues);
	}
	
	reflex update_temps{
		temps <- (temps = gouv.duree_regime)? 0 : temps +1;
	}
}


experiment exec {	
	
	// les parameters 
	parameter 'type de regime du gouvermen' var:regime among:DEFAULT_REGIME;
	parameter "duree regime" var: dureMandat max: (regime = DEFAULT_REGIME[0])?5:20 min:5 step: 5; 
		
	
	
	output {
		
		
		
	}
}