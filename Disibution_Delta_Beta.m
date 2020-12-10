% Étude statistique de la distribtuion des indice de fiabilité calculés 
% Les comparaisons se feront entre les intervalles [2010-2014] et [2014-2018] }

%% Importation des données

% [I_tot]
tableBeta_Itot = readtable('Résultats/BETA_PARC_HYDRO.csv'   ,'Delimiter',';');
% [I1]
tableBeta_I1   = readtable('Résultats/BETA_PARC_HYDRO_I1.csv','Delimiter',';');
% [I2]
tableBeta_I2   = readtable('Résultats/BETA_PARC_HYDRO_I2.csv','Delimiter',';');

% Concaténation
tableBeta_I1_I2 = horzcat(tableBeta_I1(:,1:5),tableBeta_I2(:,1:5));

% Récupération des données Été
donneesEte =   rmmissing(tableBeta_I1_I2  (:,{'Nom_I1','Num_Centrale_I1','Num_Alternateur_I1','Beta_ete_I1'  ,'Beta_ete_I2'  })) ;
% Récupération des données Hiver
donneesHiver = rmmissing(tableBeta_I1_I2  (:,{'Nom_I1','Num_Centrale_I1','Num_Alternateur_I1','Beta_hiver_I1','Beta_hiver_I2'})) ;

% Gestion des données infinies
if isinf((donneesHiver{71,4}))
    donneesHiver{71,4} = NaN; 
end

donneesEte   = rmmissing(donneesEte)   ;
donneesHiver = rmmissing(donneesHiver) ;


donneesGlobales = rmmissing(tableBeta_Itot(:,{'Nom','Num_Centrale','Num_Alternateur','Beta_ete','Beta_hiver'})) ;

%% Extraction des caractéristiques
% Été
beta_ete_I1 = table2array(donneesEte(:,'Beta_ete_I1'));
beta_ete_I2 = table2array(donneesEte(:,'Beta_ete_I2'));
Num_Centrales_Ete = table2array(donneesEte(:,'Num_Centrale_I1'));
Nom_Centrales_Groupes_ete = table2array(donneesEte(:,'Nom_I1'));
% Hiver
beta_hiver_I1 = table2array(donneesHiver(:,'Beta_hiver_I1'));
beta_hiver_I2 = table2array(donneesHiver(:,'Beta_hiver_I2'));
Num_Centrales_Hiver = table2array(donneesHiver(:,'Num_Centrale_I1'));
Nom_Centrales_Groupes_hiver = table2array(donneesHiver(:,'Nom_I1'));



%% Tracé de la dispersion entre les betas ([I1]) et les betas ([I2])
close all

% Été
figure()
scatter(beta_ete_I1,beta_ete_I2,25,"filled")
hold on 
plot(linspace(0,6,100),linspace(0,6,100))
hold on 
plot(linspace(0,6,100),linspace(0,6,100)+1,'Color',[0.9290 0.6940 0.1250],'LineStyle','--')
hold on 
plot(linspace(0,6,100),linspace(0,6,100)-1,"Color",[0.9290 0.6940 0.1250],'LineStyle','--')
title(sprintf("\nH = " +  num2str(ttest2(beta_ete_I1,beta_ete_I2))...
          ))
grid on 
saveas(gcf,'DeltaBeta/'+"betaI2=f(betaI1) ete"+'.png')

% Hiver
figure()
scatter(beta_hiver_I1,beta_hiver_I2,25,"filled")
hold on 
plot(linspace(0,6,100),linspace(0,6,100))
hold on 
plot(linspace(0,6,100),linspace(0,6,100)+1,'Color',[0.9290 0.6940 0.1250],'LineStyle','--')
hold on 
plot(linspace(0,6,100),linspace(0,6,100)-1,"Color",[0.9290 0.6940 0.1250],'LineStyle','--')
title(sprintf("\nH = " +  num2str(ttest2(beta_hiver_I1,beta_hiver_I2))...
          ))
grid on 
saveas(gcf,'DeltaBeta/'+"betaI2=f(betaI1) hiver"+'.png')




%%
figure()
% scatter(beta_hiver_I1,beta_hiver_I2,25,"filled")
% hold on 
gscatter(beta_hiver_I1,beta_hiver_I2,Nom_Centrales_Groupes_hiver)
hold on 
m = beta_hiver_I1/beta_hiver_I2 ;
plot(beta_hiver_I1,m*beta_hiver_I2,'LineWidth',2);
hold on 
plot(beta_hiver_I1,m*beta_hiver_I2+0.5,'Color',[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
hold on 
plot(beta_hiver_I1,m*beta_hiver_I2-0.5,"Color",[0.9290 0.6940 0.1250],'LineStyle','--','LineWidth',2)
grid on
xlabel("Indice Beta I1")
ylabel("Indice Beta I2")
title(sprintf(" Hiver " ))
legend("Groupe","Droite de Corrélation")
% saveas(gcf,'DeltaBeta/'+"deltaBetaHiverCorrelation"+'.png')



%% Boites à moustaches 
% Hiver
figure()
boxplot([beta_hiver_I1 beta_hiver_I2],'Notch','off', ...
        'Labels',{'Beta Hiver I1','Beta Hiver I2'})
box off
grid on
[h,p] = ttest2(beta_hiver_I1,beta_hiver_I2,'Alpha',0.05);
saveas(gcf,'DeltaBeta/Boites/'+"boitesHiver"+'.png')

% Été
figure()
boxplot([beta_ete_I1 beta_ete_I2],'Notch','off', ...
        'Labels',{'Beta Été I1','Beta Été I2'})
    
box off
grid on
[h,p] = ttest2(beta_ete_I1,beta_ete_I2,'Alpha',0.05);
saveas(gcf,'DeltaBeta/Boites/'+"boitesEte"+'.png')




figure()
X = categorical(donneesGlobales.Nom);
Y = donneesGlobales.Beta_ete;
bar(X,Y)
xtickangle(45)
grid on 
box off 







