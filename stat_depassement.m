% Étude statistique de la distribtuion des dépassements
% Les comparaisons se feront entre les intervalles [I1] et [I2] 

%% Importation des données

% [Itot]
tableDepassement_Itot = readtable('Résultats/BETA_PARC_HYDRO.csv','Delimiter',';');  
% [I1]
tableDepassement_I1 =   readtable('Résultats/Depassement_PARC_HYDRO_I1.csv','Delimiter',';');
% [I2]
tableDepassement_I2 =   readtable('Résultats/Depassement_PARC_HYDRO_I2.csv','Delimiter',';');


%% Reformatage de la table

% Concaténation horizontale de la table I1 et de la table I2
tableDepassement = horzcat (tableDepassement_I1,tableDepassement_I2);
tableDepassement = tableDepassement(:,[1 2 3 4 8]);
tableDepassement = horzcat(tableDepassement,tableDepassement_Itot(:,'tauDepassement'));
tableDepassement = tableDepassement(tableDepassement.tauDepassement > 0 ,:);


% Calcul du pourcentage de dépassement Itot
pourcentageDepassement_Itot = table2array(tableDepassement (:,'tauDepassement'))*100;
% Calcul du pourcentage de dépassement I1
pourcentageDepassement_I1 = table2array(tableDepassement (:,'tauDepassement_I1'))*100;
% Calcul du pourcentage de dépassement I2
pourcentageDepassement_I2 = table2array(tableDepassement (:,'tauDepassement_I2'))*100;

% Récupération du vecteur contenant le nom des centrales
nomCentrales =  table2array(tableDepassement (:,'Nom_I1'));


%% Diagramme en barre des dépassements des limites physiques pour toutes les centrales
figure()
X = categorical(nomCentrales);
Y = pourcentageDepassement_Itot;
bar(X,Y)
xtickangle(45)
grid on 
box off 
title("Pourcentage du dépassement de capacité des alternateurs Itot")

close all


% %% Diagramme en barre des dépacements en I2 en fonction des I1
% figure()
% scatter(pourcentageDepassement_20102014,pourcentageDepassement_20142018,25,"filled")
% hold on 
% m = pourcentageDepassement_20102014/pourcentageDepassement_20142018 ;
% plot(pourcentageDepassement_20102014,m*pourcentageDepassement_20142018,'LineWidth',2);
% % hold on 
% % plot(pourcentageDepassement_20102014,m*pourcentageDepassement_20142018+0.5,'Color',[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
% % hold on 
% % plot(depassement_1014,m*depassement_1418-0.5,"Color",[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
% grid on
% xlabel("Taux de dépassement 2010-2014")
% ylabel("Taux de dépassement 2014-2018")
% title("Pourcentage du dépassement de capacité des alternateurs I2 en fonction de I1")
% % saveas(gcf,'DeltaBeta/'+"deltaBetaHiverCorrelation"+'.png')

