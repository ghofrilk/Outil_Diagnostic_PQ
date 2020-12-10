
%% Récupération du nom codes des variables dans le fichier de production et tracé des espaces opérationnelles

% %% Récupération des fichiers de données 
% % Récupération des données de production PQ 
% MX_moyenne = readtable('Total/MX_moy_1h.csv'); %% Chaque point correspond à la moyenne de production pendant une heure
% MW_moyenne = readtable('Total/MW_moy_1h.csv'); %% Chaque point correspond à la moyenne de production pendant une heure
% % Récupération des caractéristiques technologiques de l'aternateur 
% carac_alternateurs = readtable('C:/Users/YG1135/Documents/Data/Caractéristiques alternateurs/carac_alternateurs.xlsx');
% % Récupération des codes SCADA des alternateurs 
% centraleCodeScada = readtable('C:/Users/YG1135/Documents/Data/Données Production/MX_MW/Centrale selon code SCADA.xlsx');
% % Récupération des limites des alternateurs
% tableLimitesAlternateurs = readtable('C:/Users/YG1135/Documents/Data/Courbe de capacité/Donnees_Courbes_Limites.xlsx');


%% Déclaration variables globales

%Liste des nom de centrales + groupe dans le fichier MX_moyenne 
MX_nomVariable = sort(MX_moyenne.Properties.VariableNames(2:end)) ; 
%Liste des nom de centrales + groupe dans le fichier MW_moyenne
MW_nomVariable = sort(MW_moyenne.Properties.VariableNames(2:end)) ; 

%Nombre d'alternateur présent dans le fichier des codes SCADA
nbCentrales = length(centraleCodeScada.Centrale); 
%Nombre d'alternateur à traiter
nbAlternateurs = length(MX_nomVariable) ; 

% Création du ficher stockant les résultats finaux
resultats_finaux = zeros(1,12); 
resultats = zeros(1,12);
nom = [];


%% Itération sur tous les alternateurs 
for indice = 1:nbAlternateurs
    
    stringATrouver= MX_nomVariable{indice};

   % chercher instance et numero groupe centrale
    trouve = 0;
    indice_scada = 1;
    while (trouve == 0 && indice_scada <= (length(centraleCodeScada.CodeSCADA)-1) )
    
        array = strfind(stringATrouver,centraleCodeScada.CodeSCADA{indice_scada}) ;
        if isempty(array) 
            trouve = 0 ;
        else
            trouve = 1 ;
        end
    
        indice_scada = indice_scada + 1 ;
    
    end
    if (trouve ==0)
        continue
    end
    indice_scada = indice_scada - 1 ;
    
    % Récupération du numéro d'instance
    instance = table2array(centraleCodeScada(indice_scada,'Inst'));
    % Récupération du numéro d'Alternateur
    numeroAlternateur = regexp(stringATrouver,'\d*','Match');
    numeroAlternateur = str2double(numeroAlternateur {end});
    
    % Récupération du nom de centrale et de groupe
    nomCentraletGroupe =  strrep(convertCharsToStrings(MX_nomVariable{indice}),'_'," ");
    nomCentraletGroupe = strrep(nomCentraletGroupe,'MX',"");
    
    
   %% Gestion Alarmes 
   
   [nbAlarmes] = gestion_alarmes (listeAlarmesAlternateurs,instance,numeroAlternateur);
    
    
    %% Récupération de la production de l'alternateur 
    
    MX_iteration_prefiltrage = MX_moyenne(:,{'Date',MX_nomVariable{indice}});
    MW_iteration_prefiltrage = MW_moyenne(:,{'Date',MW_nomVariable{indice}});
    
    %% Filtrage données de production (élimination des points où la machine
    %% est à l'arrêt
       
    [MX_iteration,MW_iteration] = filtrageDonnees (MX_iteration_prefiltrage,MW_iteration_prefiltrage);
    
    %% Fenêtrage 2010_2014
    rows_fonctionnement_fenetre = (MX_iteration.Date < datetime(2014,01,01));
    MX_iteration = MX_iteration(rows_fonctionnement_fenetre,:);
    MW_iteration = MW_iteration(rows_fonctionnement_fenetre,:);

    %% Décomposition Été Hiver
    
    rows_ete = (MX_iteration.Date.Month > 6 & MX_iteration.Date.Month < 10);
    rows_hiver = (MX_iteration.Date.Month <= 6 | MX_iteration.Date.Month >= 10);
    
 
    
    MXLocal = table2array(MX_iteration(:,2));
    MWLocal = table2array(MW_iteration(:,2));
    MXLocalEte = table2array(MX_iteration(rows_ete,2));
    MWLocalEte=  table2array(MW_iteration(rows_ete,2));
    MXLocalHiver= table2array(MX_iteration(rows_hiver,2));
    MWLocalHiver= table2array(MW_iteration(rows_hiver,2));
    

    %% Récupération des caractéristiques des alternateurs

    rows = (tableLimitesAlternateurs.Inst == instance & tableLimitesAlternateurs.Groupe == numeroAlternateur & tableLimitesAlternateurs.Mois >= 1 );
    limites = tableLimitesAlternateurs (rows,:) ;
    if isempty(limites)
        continue
    end
    
    %% Création de la courbe de capacité
     if  isnan(limites.MW_rea(1)) && limites.MX_const(1) ~= 1
        MW_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MWMax')));
        MX_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MX')));
        MW_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MWMax')));
        MX_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MX')));
        
        MVA_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MVAMax')));
        MVA_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MVAMax')));
        
%         % En MW MAX
%         [MXcap_ete,MWcap_ete,indice_reactif_ete] = creerCourbeCapacite(MW_max_iteration_ete,-MX_max_iteration_ete,MX_max_iteration_ete) ;
%         [MXcap_hiv,MWcap_hiv,indice_reactif_hiver] = creerCourbeCapacite(MW_max_iteration_hiver,-MX_max_iteration_hiver,MX_max_iteration_hiver) ;
        
        % En MVA MAX
        [MXcap_ete,MWcap_ete,indice_reactif_ete] = creerCourbeCapacite(MVA_max_iteration_ete,-MX_max_iteration_ete,MX_max_iteration_ete) ;
        [MXcap_hiv,MWcap_hiv,indice_reactif_hiver] = creerCourbeCapacite(MVA_max_iteration_hiver,-MX_max_iteration_hiver,MX_max_iteration_hiver) ;
        
        [tauMotorisation,tauDepassement] = performances (MXLocal,MWLocal,rows_ete,rows_hiver,MVA_max_iteration_ete,MVA_max_iteration_hiver,MX_max_iteration_ete,...
         MX_max_iteration_hiver);
     
     
     elseif limites.MX_const(1)==1
         MW_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MWMax')));
         MW_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MWMax')));
         
         MX_max_iteration_hiver = table2array(limites(1,'MX_rea_sup'));
         MX_max_iteration_ete = table2array(limites(1,'MX_rea_sup'));
         
         MVA_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MVAMax')));
         MVA_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MVAMax')));
        
%         % En MW MAX
%         [MXcap_ete,MWcap_ete,indice_reactif_ete] = creerCourbeCapacite(MW_max_iteration_ete,-MX_max_iteration_ete,MX_max_iteration_ete) ;
%         [MXcap_hiv,MWcap_hiv,indice_reactif_hiver] = creerCourbeCapacite(MW_max_iteration_hiver,-MX_max_iteration_hiver,MX_max_iteration_hiver) ;
        
                
        % En MVA MAX
        [MXcap_ete,MWcap_ete,indice_reactif_ete] = creerCourbeCapacite(MVA_max_iteration_ete,-MX_max_iteration_ete,MX_max_iteration_ete) ;
        [MXcap_hiv,MWcap_hiv,indice_reactif_hiver] = creerCourbeCapacite(MVA_max_iteration_hiver,-MX_max_iteration_hiver,MX_max_iteration_hiver) ;
        
                % Calcul des performances associés
        [tauMotorisation,tauDepassement] = performances (MXLocal,MWLocal,rows_ete,rows_hiver,MVA_max_iteration_ete,MVA_max_iteration_hiver,MX_max_iteration_ete,...
         MX_max_iteration_hiver);
        
      elseif limites.MX_const(1)==0       
          
        MW_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MWMax')));
        MW_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MWMax')));
        
        vecteur_P_rea = limites.MW_rea(~isnan(limites.MW_rea));
        vecteur_MX_rea_sup = limites.MX_rea_sup(~isnan(limites.MX_rea_sup));
        
         MVA_max_iteration_ete = mean(table2array(limites(limites.Mois > 6 | limites.Mois < 10 ,'MVAMax')));
         MVA_max_iteration_hiver = mean(table2array(limites(limites.Mois <= 6 | limites.Mois >= 10 ,'MVAMax')));
        
%          % En MW MAX
%         [MXcap_ete,MWcap_ete,indice_reactif_ete] = creerCourbeCapaciteVariable(MW_max_iteration_ete,vecteur_P_rea,vecteur_MX_rea_sup);
%         [MXcap_hiv,MWcap_hiv,indice_reactif_hiver] = creerCourbeCapaciteVariable(MW_max_iteration_hiver,vecteur_P_rea,vecteur_MX_rea_sup);  
        
        % En MVA MAX
        [MXcap_ete,MWcap_ete,indice_reactif_ete] = creerCourbeCapaciteVariable(MVA_max_iteration_ete,vecteur_P_rea,vecteur_MX_rea_sup);
        [MXcap_hiv,MWcap_hiv,indice_reactif_hiver] = creerCourbeCapaciteVariable(MVA_max_iteration_hiver,vecteur_P_rea,vecteur_MX_rea_sup);  
        
        % Calcul des performances associés
        [tauMotorisation,tauDepassement] = performances_axe_reactif_variable (MXLocal,MWLocal,rows_ete,rows_hiver,MVA_max_iteration_ete,MVA_max_iteration_hiver,vecteur_P_rea,...
         vecteur_MX_rea_sup);
        
     end

    
%     %% Calcul des performances
%     
%     [tauMotorisation,tauDepassement] = performances (MXLocal,MWLocal,rows_ete,rows_hiver,MVA_max_iteration_ete,MVA_max_iteration_hiver,MX_max_iteration_ete,...
%     MX_max_iteration_hiver);
    
    %% Analyse de la fiabilité Structurelle
   
    % Ete 
    
    if ~isempty(table2array(MX_iteration(rows_ete,MX_nomVariable{indice})))
        [beta_ete_global,beta_ete_reactive,beta_ete_active,PDegradationEte] = indice_fiabilites(table2array(MX_iteration(rows_ete,MX_nomVariable{indice})),...
        table2array(MW_iteration(rows_ete,MW_nomVariable{indice})),...
        MXcap_ete,MWcap_ete,indice_reactif_ete,nomCentraletGroupe,'Été');
    else
        beta_ete_global=NaN;
        beta_ete_reactive = NaN;
        beta_ete_active = NaN;
        PDegradationEte = NaN ;
    end  
    
    % Hiver
    
    
    if ~isempty(table2array(MX_iteration(rows_hiver,MX_nomVariable{indice})))
        
        [beta_hiver_global,beta_hiver_reactive,beta_hiver_active,PDegradationHiver] = indice_fiabilites(table2array(MX_iteration(rows_hiver,MX_nomVariable{indice})),...
        table2array(MW_iteration(rows_hiver,MW_nomVariable{indice})),...
        MXcap_hiv,MWcap_hiv,indice_reactif_hiver,nomCentraletGroupe,'Hiver');
    else
        beta_hiver_global=NaN;
        beta_hiver_reactive = NaN;
        beta_hiver_active = NaN;
        PDegradationHiver = NaN ;        
    end
    
     %% Tracer de l'espace Gaussien 
    
    
%     
%     saveas(fig_espace_guassien,"Figures/FiguresOPEspaceGaussien/20102014/Courbe de conception " + nomCentraletGroupe +".png")

     

    %% Création tableau de résultats 
    nom = [ nom , nomCentraletGroupe ] ;  
    resultats(1,1) = instance ;
    resultats(1,2) = numeroAlternateur ;
    resultats(1,3) = beta_ete_global ;
    resultats(1,4) = beta_ete_active ;
    resultats(1,5) = beta_ete_reactive ;
    resultats(1,6) = beta_hiver_global ;
    resultats(1,7) = beta_hiver_active ;
    resultats(1,8) = beta_hiver_reactive ;
    resultats(1,9) = tauMotorisation*100 ;
    resultats(1,10) = PDegradationEte ;   
    resultats(1,11) = PDegradationHiver ;   
    resultats(1,12) = tauDepassement;
    resultats_finaux = [resultats_finaux ;resultats ];
    
    
    % Tracé de l'espace opérationnelle
     [fig_carac,fig_sanscarac]=tracerEspaceOperationnelle(MXLocalEte,MWLocalEte,MXLocalHiver,MWLocalHiver,MXcap_ete,MWcap_ete,MXcap_hiv,MWcap_hiv,nomCentraletGroupe,...
       tauMotorisation*100,beta_ete_global,beta_hiver_global,tauDepassement,nbAlarmes,PDegradationEte,PDegradationHiver);
   
    saveas(fig_carac,'Figures/FiguresOP_20102014_carac/'+nomCentraletGroupe+'.png');
    saveas(fig_sanscarac,'Figures/FiguresOP_20102014_sanscarac/'+nomCentraletGroupe+'.png');

    %% Vidange
    clear fig_carac fig_sanscarac fig_espace_guassien 
    clear tauDepassement tauMotorisation beta_ete_global beta_ete_active beta_ete_reactive beta_hiver_global beta_hiver_active beta_hiver_reactive 
    clear PDegradationEte PDegradationHiver
    close all
      
end

%% Exportation des résultats
 
nom = transpose(nom);
resultats_finaux = resultats_finaux(2:end,:);

tablenom = array2table(nom(:,:));
tablenom.Properties.VariableNames = ["Nom_I1"];

tableResultats = array2table(resultats_finaux(:,:));
tableResultats.Properties.VariableNames =   ["Num_Centrale_I1","Num_Alternateur_I1","Beta_ete_I1","Beta_ete_active","Beta_ete_reactive","Beta_hiver_I1",...
                                            "Beta_hiver_active","Beta_hiver_reactive","Pourcentage_motorisation","PDegradationEte","PDegradationHiver_I1"...
                                            "tauDepassement_I1"];

                    


tableResultats = horzcat(tablenom,tableResultats);



 tableResultatsReduits20102014 = tableResultats(:,[1 2 3 4 7 12 13]);
 
 
 tableDepassement20102014 = tableResultats(:,[1 2 3 13]);
 

writetable(  tableResultatsReduits20102014,'Résultats/BETA_PARC_HYDRO_I1.csv'       ,'Delimiter',';');
writetable(  tableDepassement20102014     ,'Résultats/Depassement_PARC_HYDRO_I1.csv','Delimiter',';');


