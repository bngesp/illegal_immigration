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
	int mois <-0 ;
	int dureMandat <- 0;
	int annee<-0;
	int emploi_disponible <- 0;
	string regime<- "";
	list<string> DEFAULT_REGIME <- [ "COURT", "LONG"];
	int aideEntreprenariat <- rnd(10);
	int gestionRessource <- rnd(10);
	
	init{
		
		create gouvernement number:1{
			gestion_ressource <- gestionRessource;
			self.regime <- regime;
			aide_entreprenariat<- aideEntreprenariat;
			duree_regime<- dureMandat;
		}
		if(mois = 13){
			mois<- 1;
			annee <- annee +1;
		}
	}
	
	
}


species gouvernement{
	int gestion_ressource;
	string regime;
	int aide_entreprenariat;
	int duree_regime; 
	int richesse_pays<- 0;
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
		}
	}
	reflex creer_emploi{
		emploi_disponible<-emploi_disponible + ((gestion_ressource+1)*700);
	}
	reflex generer_richesse{
		richesse_pays <- richesse_pays + gestion_ressource*10000;
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
	int budget;
	int niveau_sensibilisation;
	int politique_externe;
	
	reflex trouver_travail when: estChomeur{
		if(emploi_disponible >0)
		{
			estChomeur <- false;
			revenue<-revenue + (niveau_alphabetisation*96000); 
			emploi_disponible <- emploi_disponible-1;
		}
	}
	reflex augmenter_compte{
		if(!estChomeur){
			compte <- compte + revenue/10;
			if(a_une_entreprise){
				compte<- compte + (budget/10)*3;
			}
		}else{
			if(est_entrepreneur){
				compte <- compte + rnd(-1,2)*10000;	
			}else{
				compte <- compte + rnd(-1,1)*10000;
			}
			if(a_une_entreprise){
				compte<- compte + (budget/10)*3;
			}
		}
		
	}
	reflex creation_entreprise when:est_entrepreneur and !a_une_entreprise{
		if(estChomeur){
			if(compte>=100000){
				ask pays_sud{
					nbr_entrepreneurs <-nbr_entrepreneurs + 1;
				}
				emploi_disponible <- emploi_disponible + 1;
				budget <- compte/2;
			}
		}else{
			if(compte>revenue*2){
				ask pays_sud{
					nbr_entrepreneurs <-nbr_entrepreneurs + 1;
				}
				emploi_disponible <- emploi_disponible + 2;
				budget <- compte/2;
			}
		}
	}
	reflex grandir when: mois = 12{
		age <- age +1;
	}
	reflex sortir_etude when: age = 36{
		do die;
	}
	reflex immigrer when: mois=6 or mois=12 {
		//Condition d'immigration a définir indice défini par le revenue, niveau sensibilisation et politique immigration extérieur et chance de survie
		int compte_normalise;	
		if(compte>=100000){
			compte_normalise <- 10;
		}
		if(compte<=10000){
			compte_normalise <- 1;
		}
		if(compte>10000 and compte <100000){
			compte_normalise <- compte/10000;
		}
		ask pays_nord{
			myself.politique_externe <- politique_immigration;
		}
		int seuil_immigration <- compte_normalise*6 + niveau_sensibilisation*4 + politique_externe*4 + rnd(0,1);
		if(seuil_immigration > 70){
			ask pays_sud{
				nbr_immigres <- nbr_immigres + 1; 
			}
		}
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
	int nbr_immigres;
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
	parameter "type de regime du gouvermen" var:regime  among: [ "COURT", "LONG"];
	parameter "duree regime" var: dureMandat max: 20 min:5 step: 5; 
		
	
	
	output {
		
		
		
	}
}