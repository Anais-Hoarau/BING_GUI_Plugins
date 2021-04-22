classdef ObserverObservableTest < TestCase & fr.lescot.bind.observation.Observer & fr.lescot.bind.observation.Observable
    
    properties(Access = private)
        receivedMessage = '';
    end
    
    methods
        
        function this = ObserverObservableTest(name)
            this = this@TestCase(name);
        end
        
        function tearDown(this)
            this.receivedMessage = '';
            this.removeAllObservers();
        end
        
        function update(this, message)
            this.receivedMessage = message;            
        end
        
        function testAddGetAndRemoveObservers(this)
            obs1 = fr.lescot.bind.test.observation.MockUpObserver();
            obs2 = fr.lescot.bind.test.observation.MockUpObserver();
            this.addObserver(obs1);
            assertEqual(obs1, this.getAllObservers{1});
            this.removeObserver(obs1);
            assertTrue(isempty(this.getAllObservers()));
            this.addObservers({obs1 obs2});
            assertEqual({obs1 obs2}, this.getAllObservers());
            this.removeObserver(obs2);
            assertEqual({obs1}, this.getAllObservers());
            this.addObserver(obs2);
            assertEqual({obs1 obs2}, this.getAllObservers());
            this.removeAllObservers();
            assertTrue(isempty(this.getAllObservers()));
        end
        
        function testTypeChecking(this)
            obs = fr.lescot.bind.test.observation.MockUpObserver();
                        
            f = @()this.addObserver('toto');
            assertExceptionThrown(f, 'Observable:ArgumentClassDoesNotMatch');
            assertTrue(isempty(this.getAllObservers()));
            
            f = @()this.addObservers({obs 'toto'});
            assertExceptionThrown(f, 'Observable:addObservers:ArgumentClassDoesNotMatch');
            assertTrue(isempty(this.getAllObservers()));
            
            this.addObserver(obs);
            f = @()this.removeObserver('toto');
            assertExceptionThrown(f, 'Observable:ArgumentClassDoesNotMatch');
            assertEqual({obs}, this.getAllObservers());
            
            f = @()this.notifyAll('toto');
            assertExceptionThrown(f, 'Observable:ArgumentClassDoesNotMatch');
            assertTrue(isempty(this.receivedMessage));
        end
        
        function testNotifications(this)
            this.addObserver(this);
            message = fr.lescot.bind.kernel.TimerMessage();
            message.setCurrentMessage('STOP');
            this.notifyAll(message);
            assertEqual('STOP', this.receivedMessage.getCurrentMessage());
        end
    end
    
end

