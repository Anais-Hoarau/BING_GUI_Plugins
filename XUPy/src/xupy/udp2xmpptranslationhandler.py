#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

import SocketServer
import os
import re
import xmpp

class UDP2XMPPTranslationHandler(SocketServer.DatagramRequestHandler):

    #Initialisées par runner.py puisque ce sont des variables de classe ! CQQFD !!!
    xmpp_bot_jid = None
    xmpp_bot_password = None
    xmpp_recipient_jid = None
    logger = None
    generate_csv_log = False
    #Privé (plus ou moins)
    __xmpp_bot = None
  
    """
    Cette methode est appelée automatiquement quand un paquet est reçu.
    """
    def handle(cls):

        if UDP2XMPPTranslationHandler.__xmpp_bot == None:
            cls.logger.debug("Premiere Instanciation du bot XMPP")
            cls.make_bot()
        
        data = cls.request[0].strip()
        """
        Le simulateur LEPSIS envoie une trame UDP dont les 8 premiers octets sont
        des octets de service permettant l'horodatage et l'adressage des messages.
        Ces octets ne sont pas utiles dans notre application, donc on les strip.
        8... MAGIC NUMBER !!
        """
	message_utile = data[8:len(data)]
        cls.logger.debug("Paquet reçu de " + cls.client_address[0] + " : " + message_utile)

        """
        Etape 1 - décoder la variable data (string processing : séparation sur les ;
        puis sur les = par exemple et bâtir un table de clé/valeur que l'on veut
        passer en xmpp

        Etape 2 - forger le paquet XMPP et l'envoyer
        """
        field_array = message_utile.split(';')

        parameters_tuples_list = []
        for field in field_array:
            # la doc de re est ici http://docs.python.org/library/re.html
            regexp_match = re.search('(.*)=(.*)', field)
            if regexp_match:
                if len(regexp_match.groups()) is 2:
                    variable_name = regexp_match.group(1)
                    variable_value = regexp_match.group(2)
                    parameters_tuples_list.append((variable_name, variable_value))
        cls.send_parameters(parameters_tuples_list)
        
        if cls.generate_csv_log:
            csv_path = "packets.csv";
            do_write_headers = not os.path.exists(csv_path)
            file_handler = open(csv_path, "a")
            if do_write_headers:
                for parameters_tuple in parameters_tuples_list:
                    file_handler.write(parameters_tuple[0] + ";")
                file_handler.write("\n")
            for parameters_tuple in parameters_tuples_list:
                file_handler.write(parameters_tuple[1] + ";")
            file_handler.write("\n")
            file_handler.close()

    def send_parameters(cls, parameters_tuples_list):
        data_field_list = []
        for parameter_tuple in parameters_tuples_list:
            df = xmpp.protocol.DataField(name = parameter_tuple[0], value = parameter_tuple[1])
            data_field_list.append(df)
        data_form = xmpp.protocol.DataForm(typ = "form", title = "Donnees UDP", data = data_field_list)
        message = xmpp.protocol.Message(to = cls.xmpp_recipient_jid, payload=[data_form])
        try:
            UDP2XMPPTranslationHandler.__xmpp_bot.send(message)
        except IOError:
            cls.make_bot()
            UDP2XMPPTranslationHandler.__xmpp_bot.send(message)

    def make_bot(cls):
        jid= xmpp.protocol.JID(cls.xmpp_bot_jid)
        cls.logger.info("Tentative d'instanciation du bot avec le JID : " + str(jid))
        UDP2XMPPTranslationHandler.__xmpp_bot = xmpp.Client(jid.getDomain(),debug=[])
        con = UDP2XMPPTranslationHandler.__xmpp_bot.connect()
        if not con:
            cls.logger.critical("Impossible de connecter le bot XMPP")
        cls.logger.info("Bot connecté avec succes")
        cls.logger.info("Tentative d'authentification avec le mot de passe : " + cls.xmpp_bot_password)
        auth = UDP2XMPPTranslationHandler.__xmpp_bot.auth(jid.getNode(), cls.xmpp_bot_password,resource=jid.getResource())
        if not auth:
            cls.logger.critical("Echec de l'authentification !")
        cls.logger.info("Bot connecté avec succès en utilisant le mode suivant : " + auth)