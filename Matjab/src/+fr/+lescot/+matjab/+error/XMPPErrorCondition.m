%Class: fr.lescot.matjab.error.XMPPErrorCondition
classdef XMPPErrorCondition
    
    %We can't map directly to the value of the constant in the java class,
    %because it's an inner class, that requires non static introspection to
    %be used.
    properties(Constant)
        bad_request = 'bad-request';
        conflict = 'conflict';
        feature_not_implemented = 'feature-not-implemented';
        forbidden = 'forbidden';
        gone = 'gone';
        interna_server_error = 'internal-server-error';
        item_not_found = 'item-not-found';
        jid_malformed = 'jid-malformed';
        no_acceptable = 'not-acceptable';
        not_allowed = 'not-allowed';
        not_authorized = 'not-authorized';
        payment_required = 'payment-required';
        recipient_unavailable = 'recipient-unavailable';
        redirect = 'redirect';
        registration_required = 'registration-required';
        remote_server_error = 'remote-server-error';
        remote_server_not_found = 'remote-server-not-found';
        remote_server_timeout = 'remote-server-timeout';
        request_timeout = 'request-timeout';
        resource_constraint = 'resource-constraint';
        service_unavailable = 'service-unavailable';
        subscription_required = 'subscription-required';
        undefined_condition = 'undefined-condition';
        unexpected_request = 'unexpected-request';
    end
    
    properties(Access = private)
        smackCondition;
    end
    
    methods
        
        function this = XMPPErrorCondition(value)
            if strcmp('org.jivesoftware.smack.packet.XMPPError$Condition', class(value))
                this.smackCondition = value;
            else
                listOfConstants = fieldnames(this);
                matching = false;
                for i = 1:1:length(listOfConstants)
                    matching = matching || strcmp(value, this.(listOfConstants{i}));
                end
                if ~matching
                    throw(MException('XMPPErrorCondition:XMPPErrorCondition:IllegalArgumentException', ['"' value '" is not a legal value for the creation of an error condition. Value must be within the list of constants of the class']));
                else
                    %Complicated stuff to be able to load the inner class Condition from Java
                    classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
                    conditionClass = java.lang.Class.forName('org.jivesoftware.smack.packet.XMPPError$Condition', false, classLoader);
                    constructors = conditionClass.getConstructors();
                    constructor = constructors(1);
                    arguments = javaArray('java.lang.String', 1);
                    arguments(1) = java.lang.String(value);
                    this.smackCondition = constructor.newInstance(arguments);
                end
            end
        end
        
        function out = unwrap(this)
            out = this.smackCondition;
        end
        
        function out = toString(this)
            out = this.smackCondition.toString();
        end
        
    end
    
end

