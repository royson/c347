SYSTEM = system
L_ERL = erl -noshell 

run1: 
	erlc *.erl	
	$(L_ERL) -smp disable -s $(SYSTEM) start

clean:
	rm -f ./*.beam erl_crash.dump
