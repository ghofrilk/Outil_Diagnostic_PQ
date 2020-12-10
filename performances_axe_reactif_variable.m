
%% Fonction qui calcule les indices de performance conjoncturelle de l'exploitation lorsque la limite en puissance r�active d�pend de la puissance active %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Variables d'entr�e : 
% MX : Vecteur 1D contenant les points de puissances r�actives                
% MW : Vecteur 1D contenant les points de puissances actives                                      
% rows_ete : Vecteur 1D de variables bool�ennes des instances d'�t�
% rows_hiver : Vecteur 1D de variables bool�ennes des instances d'hiver 
% MVA_max_iteration_ete : Valeur maximale de puissance apparente admise en �t� 
% MVA_max_iteration_hiver : Valeur maximale de puissance apparente admise en
% hiver
% vecteur_P_rea : Vecteur 1D des ordonn�es de la limite de puissance r�active
% vecteur_MX_rea_sup : Vecteur 1D des abscisses de la limite de puissance r�active


%% Variables de sortie : 
% tauMotorisation : taux de motorisation             
% tauDepassement  : taux de d�passement des limites physiques   
     
function [tauMotorisation,tauDepassement] = performances_axe_reactif_variable (MX,MW,rows_ete,rows_hiver,MVA_max_iteration_ete,...
    MVA_max_iteration_hiver,vecteur_P_rea,vecteur_MX_rea_sup)


    % Motorisation
    rowsMotorisation = (MW < 0);
    nbInstanceMotorisation = length(MW(rowsMotorisation));
      
    
    %% D�composition_�t�_Hiver
    MXLocalEte = MX(rows_ete);
    MWLocalEte = MW(rows_ete);
    
    MXLocalHiver = MX(rows_hiver);
    MWLocalHiver = MW(rows_hiver);
    
    
    %% D�passement 
    
    % Vecteur 1D de variables bool�ennes des instances en d�passement des
    % limites stator en �t�
    rowsDepassementStatorEte =   (sqrt(MXLocalEte.^2 + MWLocalEte.^2 )     > MVA_max_iteration_ete    ) ;  
    
    % Vecteur 1D de variables bool�ennes des instances en d�passement des
    % limites stator en hiver
    rowsDepassementStatorHiver = (sqrt(MXLocalHiver.^2 + MWLocalHiver.^2 ) > MVA_max_iteration_hiver  ) ;
    
    % Vecteur 1D de variables bool�ennes des instances en d�passement des
    % limites rotor en �t�
    rowsDepassementRotorEte = false(length(MXLocalEte),1);
    
    % Vecteur 1D de variables bool�ennes des instances en d�passement des
    % limites rotor en hiver 
    rowsDepassementRotorHiver = false(length(MXLocalHiver),1);
    
    
    
    for i = (1:length(vecteur_P_rea)-1)
        
        
        rowsDepassementRotorEte_i = ( MWLocalEte > vecteur_P_rea(i) & MWLocalEte < vecteur_P_rea(i+1) & MXLocalEte > vecteur_MX_rea_sup(i+1)) ;
        rowsDepassementRotorEte = rowsDepassementRotorEte | rowsDepassementRotorEte_i ;
        
        
        rowsDepassementRotorHiver_i = ( MWLocalHiver > vecteur_P_rea(i) & MWLocalHiver < vecteur_P_rea(i+1) & MXLocalHiver > vecteur_MX_rea_sup(i+1)) ;
        rowsDepassementRotorHiver = rowsDepassementRotorHiver | rowsDepassementRotorHiver_i ;
    end
    
   
          
    
    rowsDepassementEte   = rowsDepassementStatorEte   | rowsDepassementRotorEte ;
    rowsDepassementHiver = rowsDepassementStatorHiver | rowsDepassementRotorHiver ;
    
    
    %% Calcul des cardinaux 
    
    % Cardinal des instances en motorisation 
    nbInstanceMotorisation = length(MW(rowsMotorisation));
    
    % Cardinal des instances en d�passement l'�t�
    nbInstanceDepacementEte = length(MXLocalEte(rowsDepassementEte)) ;
    % Cardinal des instances en d�passement l'hiver
    nbInstanceDepacementHiver = length(MXLocalHiver(rowsDepassementHiver)) ;
    
    % Cardinal des instances en d�passement au stator
    nbInstanceDepacementStator = length(MXLocalEte(rowsDepassementStatorEte)) +  length(MWLocalHiver(rowsDepassementStatorHiver));
    % Cardinal des instances en d�passement au rotor
    nbInstanceDepacementRotor  = length(MXLocalEte(rowsDepassementRotorEte)) +  length(MWLocalHiver(rowsDepassementRotorHiver));
    
   
    % Cardinal de l'ensemble des instances
    nbInstancesTotales = length(MW);
    
    % Cardinal de l'ensemble des instances en �t�
    nbInstancesTotalesEte = length(MXLocalEte);
    
    % Cardinal de l'ensemble des instances en hiver
    nbInstancesTotalesHiver = length(MXLocalHiver);
    
    
    %% Calcul des performances
       
    
    % Taux de Motorisation
    tauMotorisation = round(nbInstanceMotorisation/nbInstancesTotales,3);
    
       
    % Taux de D�passement 
    
      % Toutes saisons confondues
      tauDepassement = (nbInstanceDepacementEte +  nbInstanceDepacementHiver )/ nbInstancesTotales ;
      tauDepassement = round (tauDepassement,3);
     
    
      % Taux de D�passement en �t�
      tauDepassementEte = (nbInstanceDepacementEte / nbInstancesTotalesEte) ;
      tauDepassementEte = round (tauDepassementEte,3);
    
      % Taux de D�passement en hiver
      tauDepassementHiver = (nbInstanceDepacementHiver   / nbInstancesTotalesHiver) ;
      tauDepassementHiver = round (tauDepassementHiver,3);
    

     
end