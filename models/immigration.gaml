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
	float tmp<-0.0;
	int mois <-0 ;
	int nbr_mort<-0;
	//variables for species Gouvernement 
	int dureMandat <- 0;
	int annee<-0;
	int emploi_disponible <- 0;
	string Regime<- "";
	list<string> DEFAULT_REGIME <- [ "COURT", "LONG"];
	int aideEntreprenariat <- rnd(10);
	int gestionRessource <- rnd(10);
	
	
	//variables for species individues 
	int nbr_individues<-100000;
	
	
	//variables for pays nord 
	int exploitationRessources <- rnd(10);
	int politiqueImmigration <- rnd(10);
	bool impactElection <- false;
    
	//variable for pay sud
	float croissanceDemographique<-1.0 *rnd(100);
	float tauxSensibilisation<-1.0 *rnd(100);
	float tauxChomage<-1.0 *rnd(100);
	int tauxEntreprenariat<-rnd(100);
	float tauxAlphabetisation<-1.0 *rnd(100);
	
	//varibale for societe civile
	int sensibilisation <- rnd(100);
	
	
	init{
		create gouvernement number:1{
			gestion_ressource <- gestionRessource;
			self.regime <- Regime;
			aide_entreprenariat<- aideEntreprenariat;
			duree_regime<- dureMandat;
		}
		
		create pays_nord number:1{
			exploitation_ressources<- exploitationRessources;
			politique_immigration <- politiqueImmigration;
			impact_election <- impactElection;
		}
		
		create societe_civile number:1{
			self.sensibilisation <- sensibilisation;
		}
		
		create individues number:nbr_individues;
		
		create pays_sud number:1{
			self.croissance_demographique<- croissanceDemographique;
			self.taux_alphabetisation <- tauxAlphabetisation;
			self.taux_chomage <- tauxChomage;
			self.taux_entreprenariat<-tauxEntreprenariat;
			self.taux_sensibilisation <- tauxSensibilisation;
			self.pop <- list(individues);
			self.gouv <- gouvernement[0];
			self.sc <- societe_civile[0];
		}
	}
	reflex update_time{
		tmp <- tmp + 1 ;
		mois <- mois + 1;
		if (tmp = 61){
			tmp <- 0.0;
		}
		if(mois = 13){
			mois<- 1;
			annee <- annee +1;
		}
	}

	reflex creation when: cycle=1 {
		ask pays_sud{
			do die;
		}
		ask individues {
			do die;
		}
		ask pays_nord {
			do die;
		}
		ask gouvernement {
			do die;
		}
		
		create gouvernement number:1{
			gestion_ressource <- gestionRessource;
			self.regime <- Regime;
			aide_entreprenariat<- aideEntreprenariat;
			duree_regime<- dureMandat;
		}
		
		create pays_nord number:1{
			exploitation_ressources<- exploitationRessources;
			politique_immigration <- politiqueImmigration;
			impact_election <- impactElection;
		}
		
		create societe_civile number:1{
			self.sensibilisation <- sensibilisation;
		}
		
		create individues number:nbr_individues;
		
		create pays_sud number:1{
			self.croissance_demographique<- croissanceDemographique;
			self.taux_alphabetisation <- tauxAlphabetisation;
			self.taux_chomage <- tauxChomage;
			self.taux_entreprenariat<-tauxEntreprenariat;
			self.taux_sensibilisation <- tauxSensibilisation;
			self.pop <- list(individues);
			self.gouv <- gouvernement[0];
			self.sc <- societe_civile[0];
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
	
	reflex choix_politique when: tmp=60{
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
		emploi_disponible<-emploi_disponible + ((gestion_ressource+1)*50);
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
	
	init{
		age <- rnd(15,35);
		int tirage_alp <- rnd(1,10);
		if(tirage_alp<=tauxAlphabetisation/10){
			niveau_alphabetisation<-rnd(6,10);
		}else{
			niveau_alphabetisation<-rnd(1,5);
		}
		int tirage_ent<- rnd(1,100);
		if(tirage_ent<=tauxEntreprenariat){
			est_entrepreneur<-true;
			if(rnd(1,4)<2){
				a_une_entreprise <- true;
				budget<-rnd(50000,3000000);
				compte<-budget;
			}else{
				a_une_entreprise <- false;
				compte<-rnd(0,50000);
			}
		}else{
			est_entrepreneur<-false;
		}
		int tirage_sen<-rnd(1,10);
		if(tirage_sen<=tauxSensibilisation/10){
			niveau_sensibilisation<-rnd(6,10);
		}else{
			niveau_sensibilisation<-rnd(1,5);
		}
		int tirage_cho<-rnd(1,10);
		if(tirage_cho<=tauxChomage/10){
			estChomeur <- true;
			if(!est_entrepreneur){
				compte<-rnd(0,10000);
			}
		}else{
			estChomeur <- false;
			revenue<-niveau_alphabetisation*96000;
			compte<- int((revenue/10)*rnd(5,10));
		}
	}
	
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
			compte <- a_une_entreprise? int(compte + (budget/10)*3) : int(compte + revenue/10);
		}else{
			compte <- compte + rnd(-1,1+int(est_entrepreneur))*10000;
//			if(est_entrepreneur){
//				compte <- compte + rnd(-1,2)*10000;	
//			}else{
//				compte <- compte + rnd(-1,1)*10000;
//			}
			if(a_une_entreprise){
				compte<- int(compte + (budget/10)*3);
			}
		}
		
	}
	
	reflex creation_entreprise when:est_entrepreneur and !a_une_entreprise{
		if(estChomeur){
			if(compte>=100000){
				ask pays_sud{
					nbr_entrepreneurs <- nbr_entrepreneurs + 1;
				}
				emploi_disponible <- emploi_disponible + 1;
				budget <- int(compte/2);
				a_une_entreprise <- true;
			}
		}else{
			if(compte>revenue*2){
				ask pays_sud{
					nbr_entrepreneurs <-nbr_entrepreneurs + 1;
				}
				emploi_disponible <- emploi_disponible + 2;
				budget <- int(compte/2);
				a_une_entreprise <- true;
			}
		}
	}
	
	reflex grandir when: mois = 12{
		age <- age +1;
	}
	
	reflex sortir_etude when: age = 36{
		nbr_mort<-nbr_mort+1;
		do die;
		
	}
	
	reflex immigrer when: mois=6 or mois=12{
		//Condition d'immigration a définir indice défini par le revenue, niveau sensibilisation et politique immigration extérieur et chance de survie
		int compte_normalise;	
		if(compte>=100000){
			compte_normalise <- 10;
		}
		if(compte<=10000){
			compte_normalise <- 1;
		}
		if(compte>10000 and compte <100000){
			compte_normalise <- int(compte/10000);
		}
		ask pays_nord{
			myself.politique_externe <- politique_immigration;
		}
		int depart <- rnd(0,1);
		int seuil_immigration <- compte_normalise*6 + niveau_sensibilisation*4 + politique_externe*4;
		if(seuil_immigration < 70){
			if( depart = 1){
				ask pays_sud{
					nbr_immigres <- nbr_immigres + 1; 
				}
			nbr_mort<-nbr_mort+1;
			do die;
			
			}else{
				ask pays_sud{
					nbr_tentatives_depart	<- nbr_tentatives_depart + 1; 
				}
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
   
    int richesse_pays<- 0;
    
    reflex s_enrichir{
    	richesse_pays <- richesse_pays + exploitation_ressources*10000;
    }
    reflex election when: temps=dureMandat*12{
    	exploitation_ressources <- rnd(10);
    	politique_immigration <- rnd(10);
    	impact_election <- rnd(0,1);	
    }


}

species pays_sud{
	gouvernement gouv;
	list<individues> pop;
	societe_civile sc;
	float croissance_demographique;
	float taux_alphabetisation;
	int nbr_entrepreneurs;
	int nbr_immigres<- 0;
	int nbr_tentatives_depart<- 0;
	int nbr_chomeurs<- 0;
//	bool estStable;
	float taux_sensibilisation;
	float taux_entreprenariat;
	float taux_chomage;
	int nbr_hbt_a_sensibiliser <- 0;
	
	
//	init{
//		pop <- list(individues);
//		write "la list des individus "+ pop;
//	}
	
//	reflex creation when: cycle=1 {
//		pop <- list(individues);
//		write "la list des individus "+ pop;
//	}
	reflex sensibiliser{
		//int impact_sensbilisation;
		pop <- list(individues);
		int nbr_hbt <- length(pop);
		
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
					//if(pop[vrr]!= nil) {
						pop[vrr].niveau_sensibilisation <- (pop[vrr].niveau_sensibilisation + sc.sensibilisation ) mod 10 ;
					//}
				}
			}
			
		}
	}
	
	reflex update_pop when: (temps mod 12) = 0{
		int peuple <- length(pop);
		int augmentation <- int(peuple*(croissance_demographique/100));
		create individues number:augmentation;
		pop <- list(individues);
	}
	
	reflex update_temps{
		temps <- (temps = gouv.duree_regime)? 0 : temps +1;
	}
	
	reflex update_chomeur{
		 nbr_chomeurs<- 0;
		loop i over:pop{
			if(i.estChomeur){
				nbr_chomeurs <- nbr_chomeurs+1;
			}
		}
		
	}

}


experiment exec {	
	
	// les parameters Gouvernement
	parameter "type de regime du gouverment" var:Regime  among: [ "COURT", "LONG"] category:gouvernement;
	parameter "duree regime" var: dureMandat max: 20 min:5 step: 5 category:gouvernement; 
	parameter "echelle aide a l'entreprenariat" var:aideEntreprenariat max:10 min:1 category:gouvernement;
	parameter "echelle de la gestion des ressources" var:gestionRessource max:10 min:1 category:gouvernement;
	
	// Individues
	parameter "taille de la population " var:nbr_individues min:1 category:"population";
	parameter "la croissance demo " var:croissanceDemographique max:10.0 min:1.0 category:"population";
	parameter "taux de sensibilisation " var:tauxSensibilisation max:100.0 min:1.0 category:"population";
	parameter "taux de chomage " var:tauxChomage max:100.0 min:1.0 category:"population";
	parameter "taux de l'entreprenariat" var:tauxEntreprenariat max:100 min:1 category:"population";
	parameter "taux de l'alphabetisation " var:croissanceDemographique max:100.0 min:1.0 category:"population";
	
	// societe civile
	parameter "degre d'impact de la sensibilisation" var:sensibilisation max:10 min:1 category:"Societe civile";
	
	// pays exploitant
	parameter "niveau d'exploitation des ressource" var:exploitationRessources max:10 min:1 category:"Pays etranger";
	parameter "politique d'immigration" var:politiqueImmigration max:10 min:1 category:"Pays etranger";
	parameter "impact dans les elections" var:impactElection init:false category:"Pays etranger";

	output {
		
		monitor "la population est : " value:length(pays_sud[0].pop);
		monitor "le nombre d'entrepreneur =>  " value:pays_sud[0].nbr_entrepreneurs;
		monitor "le nombre d'immigrer =>  " value:pays_sud[0].nbr_immigres;
		monitor "le de tentative de depart =>  " value:pays_sud[0].nbr_tentatives_depart;
		monitor "le nombre de chomeur =>  " value:pays_sud[0].nbr_chomeurs;
		monitor "le nombre d'emploi disponible =>  " value:emploi_disponible;
		//monitor "le nombre de depart =>  " value:nbr_mort;
		
		display courbe{
			chart "Immigration clandestine" type:series x_label:"mois" y_label:"nombre de personnes"{
				data "evolution du nombre d'immigre" value:pays_sud[0].nbr_immigres color:#red;
				data "evolution taux de chomage" value:pays_sud[0].nbr_chomeurs color:#blue;
			}
		}
	}
}