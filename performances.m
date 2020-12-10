
%% Fonction qui calcule les indices de performance conjoncturelle de l'exploitation lorsque la limite en puissance réactive est constante%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variables d'entrée : 
% MX : Vecteur 1D contenant les points de puissances réactives                
% MW : Vecteur 1D contenant les points de puissances actives                                      
% rows_ete : Vecteur 1D de variables booléennes des instances d'été
% rows_hiver : Vecteur 1D de variables booléennes des instances d'hiver 
% MVA_max_iteration_ete : Valeur maximale de puissance apparente admise en été 
% MVA_max_iteration_hiver : Valeur maximale de puissance apparente admise en
% hiver
% MX_max_iteration_ete : Valeur maximale de puissance réactive admise en été 
% MX_max_iteration_hiver :Valeur maximale de puissance réactive admise en hiver

%% Variables de sortie : 
% tauMotorisation : taux de motorisation             
% tauDepassement  : taux de dépassement des limites physiques                                      


function [tauMotorisation,tauDepassement] = performances (MX,MW,rows_ete,rows_hiver,MVA_max_iteration_ete,MVA_max_iteration_hiver,MX_max_iteration_ete,...
    MX_max_iteration_hiver)

    
    %% Décomposition_Été_Hiver
    MXLocalEte = MX(rows_ete);
    MWLocalEte = MW(rows_ete);
    
    MXLocalHiver = MX(rows_hiver);
    MWLocalHiver = MW(rows_hiver);
    
    
    
    %% Vecteur 1D de variables booléennes des instances en motorisation  
    rowsMotorisation = (MW < 0);
         
    %% Dépassement 
    
    % Vecteur 1D de variables booléennes des instances en dépassement des
    % limites stator en été
    rowsDepassementStatorEte = (sqrt(MXLocalEte.^2 + MWLocalEte.^2 ) > MVA_max_iteration_ete   ) ;
    
    % Vecteur 1D de variables booléennes des instances en dépassement des
    % limites stator en hiver
    rowsDepassementStatorHiver = (sqrt(MXLocalHiver.^2 + MWLocalHiver.^2 ) > MVA_max_iteration_hiver    ) ;
    
    % Vecteur 1D de variables booléennes des instances en dépassement des
    % limites rotor en été
    rowsDepassementRotorEte = ( MXLocalEte > MX_max_iteration_ete) ;
    
    % Vecteur 1D de variables booléennes des instances en dépassement des
    % limites rotor en hiver
    rowsDepassementRotorHiver = (MXLocalHiver> MX_max_iteration_hiver) ;
    
    
    % Vecteur 1D de variables booléennes des instances en dépassement
    % stator ou rotor en été
    rowsDepassementEte   = rowsDepassementStatorEte   | rowsDepassementRotorEte ;
    % Vecteur 1D de variables booléennes des instances en dépassement
    % stator ou rotor en hiver
    rowsDepassementHiver = rowsDepassementStatorHiver | rowsDepassementRotorHiver ;
    
    
    %% Calcul des cardinaux 
    
    % Cardinal des instances en motorisation 
    nbInstanceMotorisation = length(MW(rowsMotorisation));
    
    % Cardinal des instances en dépassement l'été
    nbInstanceDepacementEte = length(MXLocalEte(rowsDepassementEte)) ;
    
    % Cardinal des instances en dépassement l'hiver
    nbInstanceDepacementHiver = length(MXLocalHiver(rowsDepassementHiver)) ;
    
    % Cardinal des instances en dépassement au stator
    nbInstanceDepacementStator = length(MXLocalEte(rowsDepassementStatorEte)) +  length(MWLocalHiver(rowsDepassementStatorHiver));
    
    % Cardinal des instances en dépassement au rotor
    nbInstanceDepacementRotor  = length(MXLocalEte(rowsDepassementRotorEte)) +  length(MWLocalHiver(rowsDepassementRotorHiver));
     
    % Cardinal de l'ensemble des instances 
    nbInstancesTotales = length(MW);

    % Cardinal de l'ensemble des instances en été
    nbInstancesTotalesEte = length(MXLocalEte);
    
    % Cardinal de l'ensemble des instances en hiver
    nbInstancesTotalesHiver = length(MXLocalHiver);
     
    %% Calcul des performances
       
    % Taux de Motorisation
    tauMotorisation = round(nbInstanceMotorisation/nbInstancesTotales,3);
    
       
    % Taux de Dépassement 
    
      % Toutes saisons confondues
      tauDepassement = (nbInstanceDepacementEte +  nbInstanceDepacementHiver )/ nbInstancesTotales ;
      tauDepassement = round (tauDepassement,3);
     
    
      % Taux de Dépassement en été
      tauDepassementEte = (nbInstanceDepacementEte / nbInstancesTotalesEte) ;
      tauDepassementEte = round (tauDepassementEte,3);
    
      % Taux de Dépassement en hiver
      tauDepassementHiver = (nbInstanceDepacementHiver   / nbInstancesTotalesHiver) ;
      tauDepassementHiver = round (tauDepassementHiver,3);
    
     
end