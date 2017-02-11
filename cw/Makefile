SYSTEM = system1
L_ERL = erl -noshell -setcookie pass

run1: 
	$(L_ERL) -s $(SYSTEM) start 5

clean:
	rm -f ./*.beam erl_crash.dump
