SYSTEM = system5
L_ERL = erl -noshell 

run1: 
	erlc *.erl	
	$(L_ERL) -s $(SYSTEM) start 5 100

clean:
	rm -f ./*.beam erl_crash.dump
