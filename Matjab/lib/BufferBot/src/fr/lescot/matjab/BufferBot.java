package fr.lescot.matjab;

import java.util.Iterator;
import java.util.Vector;
import org.jivesoftware.smack.Chat;
import org.jivesoftware.smack.ChatManager;
import org.jivesoftware.smack.ChatManagerListener;
import org.jivesoftware.smack.ConnectionConfiguration;
import org.jivesoftware.smack.MessageListener;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.packet.Presence;
import org.jivesoftware.smackx.OfflineMessageManager;

/*Class: fr.lescot.matjab.BufferBot
This java class instanciantes a bot connected to a XMPP server. This bot will buffer all the received messages,
and return (and delete) them from buffer when <getBufferedMessages> is called. This class is a *java* class,
and thus is not intended to be used directly in Matlab. Use *<fr.lescot.matjab.Bot>* instead.
*/
public class BufferBot implements ChatManagerListener, MessageListener {

    /*Property: connection
     An org.jivesoftware.smack.XMPPConnection object representing the connection to the server.
     Modifiers:
     - Private*/
    private XMPPConnection connection;
    /*Property: buffer
     A Vector of org.jivesoftware.smack.packet.Message objects containing the messages received since the last
     buffer flush.
     Modifiers:
     - Private*/
    private Vector<Message> buffer;
    /*Property: serverName
     A String containing the name of the server to connect.
     Modifiers:
     - Private*/
    private String serverName;
    /*Property: serverName
     A String containing the login to use to get connected
     Modifiers:
     - Private*/
    private String login;
    /*Property: password
     A String containing the password to authenticate the connection.
     Modifiers:
     - Private*/
    private String password;
    /*Property: ressource
     A String containing the name of the connected ressource.
     Modifiers:
     - Private*/
    private String ressource;
    /*Property: ressource
     The boolean that indicated if the message received when the bot where offline should be treated or ignored.
     Modifiers:
     - Private*/
    private Boolean treatMessagesStoredOnServer;

    /*Function: BufferBot
     Build a new BufferBot with the indicated parameters. Once connected, this bot 
     will store all the messages sent to him, until they are retrieved.
     
     Arguments: 
     serverName - The name of the server.
     login - The login to use on the server.
     password - The password of the account
     ressource - The ressource to log in (http://wiki.jabberfr.org/Glossaire)
     treatMessagesStoredOnServer - Boolean value indicating if the messages sent offline to the bot must be treated (true)
     or deleted (false).
     
     Todo: 
     * Add a proxy support with constructor polymorphism
     */
    public BufferBot(String serverName, String login, String password, String ressource, Boolean treatMessagesStoredOnServer) {
        this.serverName = serverName;
        this.login = login;
        this.password = password;
        this.ressource = ressource;
        this.treatMessagesStoredOnServer = treatMessagesStoredOnServer;
        //Initialize the buffer Vector
        buffer = new Vector<Message>();
    }

    /*Function: connect
     Connect the bot to the server using the parameters passed to the constructor.
     Once connected, the bot is fully operationnal.
     
     Throws:
     org.jivesoftware.smack.XMPPException - When an XMPP error occurs.
     */
    public void connect() throws XMPPException{
        //Create the connection and connect it
        ConnectionConfiguration configuration = new ConnectionConfiguration(serverName);
        configuration.setSendPresence(false);
        connection = new XMPPConnection(configuration);
        connection.connect();
        connection.login(login, password, ressource);

        OfflineMessageManager offlineMessagesManager = new OfflineMessageManager(connection);
        //If we don't want to process offline messages, we delete them from the server.
        if (treatMessagesStoredOnServer) {
            Iterator<Message> offlineMessages = offlineMessagesManager.getMessages();
            while (offlineMessages.hasNext()) {
                processMessage(null, offlineMessages.next());
            }

        }
        offlineMessagesManager.deleteMessages();

        ChatManager chatmanager = connection.getChatManager();
        chatmanager.addChatListener(this);
        //Set presence to available.
        Presence presence = new Presence(Presence.Type.available);
        connection.sendPacket(presence);
    }

    /*Function: disconnect
     Disconnect the bot, setting it offline.
     */
    public void disconnect() {
        connection.disconnect();
    }

    /*Function: chatCreated
     This method is here to implement the method in org.jivesoftware.smack.ChatManagerListener.
     It is not private for implementations reasons, but should not be used from outside of the object.
     */
    public void chatCreated(Chat chat, boolean createdLocally) {
        chat.addMessageListener(this);
    }

    /*Function: processMessage
     This method is here to implement the method in org.jivesoftware.smack.MessageListener.
     It is not private for implementations reasons, but should not be used from outside of the object.
     */
    public void processMessage(Chat arg0, Message message) {
        buffer.addElement(message);
    }

    /*Function: getBufferedMessages
     This method returns a Vector of org.jivesoftware.smack.packet.Message objects. These objects
     are all the messages received since the last call of the method. Then, the bot inner buffer is flushed,
     and the following messages will be stored in it.
     
     Returns:
     A Vector of org.jivesoftware.smack.packet.Message
     */
    public Vector<Message> getBufferedMessages() {
        Vector<Message> bufferCopy = (Vector<Message>) buffer.clone();
        buffer.removeAll(buffer);
        return bufferCopy;
    }

    /*Function: sendMessage
     This method returns a Vector of org.jivesoftware.smack.packet.Message objects. These objects
     are all the messages received since the last call of the method. Then, the bot inner buffer is flushed,
     and the following messages will be stored in it.
     
     Arguments: 
     message - A org.jivesoftware.smack.packet.Message object, filled with all the necessary datas.
     */
    public void sendMessage(Message message) {
        connection.sendPacket(message);
    }
}
