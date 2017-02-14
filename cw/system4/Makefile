SYSTEM = system4
L_ERL = erl -noshell 

run1: 
	erlc *.erl	
	$(L_ERL) -s $(SYSTEM) start 5 0

clean:
	rm -f ./*.beam erl_crash.dump
