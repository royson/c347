SYSTEM = system
L_ERL = erl -noshell 

run1: 
	erlc *.erl	
	$(L_ERL) -s $(SYSTEM) start

clean:
	rm -f ./*.beam erl_crash.dump