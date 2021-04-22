classdef MegaConfigurator < handle
    
properties
    
    listConfig;
    
end
    
methods (Access=public)
    function this=MegaConfigurator()%constructeur
        this.listConfig={fr.lescot.bind.configurators.Configuration};
        message='Ouverture de MegaConfigurator'
        
    end
end
    
methods (Access=public)
    
    function out=getConfigurationNum(this,Num)
    
        out=this.listConfig{Num}

    end
    
    function confiName=getConfigurationWithName(this,Name)
    
        for ind=2:1:length(this.listConfig)
            c=this.getConfigurationNum(ind)
            try 
                value=c.findArgumentWithOrder(200).getValue()
                msg="ok"
                ind
                Name
                if value == Name
                       confiName=c;
                       
                end
                return;
            catch ME
                break;
            end
            
        end
        mesg="erreur"
        confiName='';
    end

    
    function out=getAllConfiguration(this)
    
        out=this.listConfig{:}

    end
    
    function addConfigurationInMega(this, configToAdd, indice)
        
        this.listConfig{indice}=configToAdd;
        
    end
    
    function addArgInConfigurationNum(this,argumentsList, NumConfig)
        try 
            this.listConfig{NumConfig}.setArguments(argumentsList);
        catch ME
            msg="Création de la configuration car non pré-existante"
            configToAdd=fr.lescot.bind.configurators.Configuration();
            this.addConfigurationInMega(configToAdd, NumConfig);
            listArg=argumentsList
            this.listConfig{NumConfig}.setArguments(argumentsList);
        end
        
    end
   
    
   function removeConfigurationInMega(this, configToAdd)
        indice=length(this.listConfig);
        this.listConfig{indice+1}=configToAdd;
        
    end


    function OuvreToutPluginAVecConfig(this,monTrip)
        import fr.lescot.bind.configurators.*
        len=length(this.listConfig)
        if len==2
            confiNumi=this.getConfigurationNum(2); %configNum(1)est vide
            %confiNumi.findArgumentWithOrder(3).getValue()
            listArgs=confiNumi.findArgumentWithOrder(100)
            fr.lescot.bind.configurators.PluginConfigurator_simplif.lancePluginStatic( monTrip,listArgs,'Magneto' )  
            m='ok len==1'  
        else
            for i= 1:1:(len-1)
                confiNumi=this.getConfigurationNum(i+1); %ou i+1 si 1ere config vide
                listArgs=confiNumi.findArgumentWithOrder(100)
                
                fr.lescot.bind.configurators.PluginConfigurator_simplif.lancePluginStatic( monTrip,listArgs,'Magneto' )
                % A CONTINUER POUR AUTRE PLUGIN
                 m='ok len==i' 
            end
        end
    end
end
    
   
end

