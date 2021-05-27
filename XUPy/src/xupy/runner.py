#!/usr/bin/python
# -*- coding: iso-8859-1 -*-import sys

import sys

import ConfigParser
import SocketServer
import logging
import xupy

""" Chargement des arguments de la commande """
arguments = sys.argv
arguments_number = len(arguments)
if arguments_number != 2:
    print("Usage : XUPy configurationFile")
    sys.exit()
#On commence les indices a 1 parce que 0 est le nom du script
path_to_config = arguments[1]

""" Analyse du fichier de conf """
config = ConfigParser.SafeConfigParser()
config.read(path_to_config)
udp_host = config.get("UDP_server", "udp_listening_adress")
udp_port = config.getint("UDP_server", "udp_listening_port")

bot_jid = config.get("XMPP_client", "bot_jid")
bot_password = config.get("XMPP_client", "bot_password")
recipient_jid = config.get("XMPP_client", "recipient_jid")

console_log_level = config.get("Logging", "console_log_level")
file_log_level = config.get("Logging", "file_log_level")
generate_csv_log = config.get("Logging", "generate_csv_log")

""" Configuration du logging """
logger = logging.getLogger("xupy")
logger.setLevel(logging.DEBUG)

console_logger = logging.StreamHandler()
console_logger.setLevel(console_log_level)
console_formatter = logging.Formatter('%(levelname)-8s: %(message)s')
console_logger.setFormatter(console_formatter)

file_logger = logging.FileHandler("xupy.log", "a")
file_logger.setLevel(file_log_level)
file_formatter = logging.Formatter("%(asctime)s - %(levelname)s: %(message)s")
file_logger.setFormatter(file_formatter)

logger.addHandler(console_logger)
logger.addHandler(file_logger)

""" Configuration des informations XMPP de la classe de handling """
xupy.UDP2XMPPTranslationHandler.xmpp_bot_jid = bot_jid
xupy.UDP2XMPPTranslationHandler.xmpp_bot_password = bot_password
xupy.UDP2XMPPTranslationHandler.xmpp_recipient_jid = recipient_jid
xupy.UDP2XMPPTranslationHandler.logger = logger
xupy.UDP2XMPPTranslationHandler.generate_csv_log = ("true" == generate_csv_log)

""" Creation du server socket """
logger.debug("Lancement du convertisseur UDP>XMPP en écoute sur " + udp_host + ":" + str(udp_port))
server = SocketServer.UDPServer((udp_host, udp_port), xupy.UDP2XMPPTranslationHandler)
server.serve_forever()