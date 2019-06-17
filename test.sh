#!/bin/bash

total=10;

declare -i counter; counter=0;
declare -i c_pass; c_pass=0;
declare -i c_fail; c_fail=0;

scenario() {
  echo -e "\nScenario \e[100m $1 \e[0m";
}


equal() {
  counter+=1;
  if [ "$out" == "$2" ]; then
      c_pass+=1;
      echo -e "($counter/$total) \e[92mPass\e[0m $1";

    else
      c_fail+=1;
      echo "  OUT: $out";
      echo "  EXP: $2";
      echo -e "($counter/$total) \e[91mFail\e[0m $1";
    fi
}

notEqual() {
  counter+=1;
  if [ "$out" != "$1" ]; then
      c_pass+=1;
      echo -e "($counter/$total) \e[92mPass\e[0m $1";

    else
      c_fail+=1;
      echo "  OUT: $out";
      echo "  EXP: $1";
      echo -e "($counter/$total) \e[91mFail\e[0m $1";
    fi
}

#
# Precheck
#

if type -P node > /dev/null
  then
    echo "node is installed"
    node -v;
  else
    echo "didn't found nodejs installed, quiting..."
    exit 1;
  fi

################
scenario "MORSE encode"

out=$(node cipher.js --type=morse --mode=encode --message="Hallo world!!!");
equal "Basic test" ".... .- .-.. .-.. --- / .-- --- .-. .-.. -..";

out=$(node cipher.js --type=morse --mode=encode --message="S O S!@#$%^&*()");
equal "Special characters filtering" "... / --- / ...";

out=$(node cipher.js --type=morse --mode=encode --message="S O S\t\n");
notEqual "\e[105mBUG #1\e[0m - TAB and NEWLINE characters should be filtered out but is not" "... / --- / ...";

out=$(node cipher.js --type=morse --mode=encode --message="ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 abcdefghijklmnopqrstuvwxyz");
equal "Test of full scope of supported language" ".- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --.. / ----- .---- ..--- ...-- ....- ..... -.... --... ---.. ----. / .- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --..";


################
scenario "MORSE decode"

out=$(node cipher.js --type=morse --mode=decode --message=".... .- .-.. .-.. --- / .-- --- .-. .-.. -..");
equal "Basic test" "hallo world";

out=$(node cipher.js --type=morse --mode=decode --message=" / ----- .---- ..--- ...-- ....- ..... -.... --... ---.. ----. / .- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --..");
notEqual "\e[105mBUG #2\e[0m - 0 is not present in dictionary" " 0123456789 abcdefghijklmnopqrstuvwxyz";


################
scenario "ROT13 encode"

out=$(node cipher.js --type=rot13 --mode=encode --message="Hallo world!!!");
equal "Basic test" "Unyyb jbeyq!!!";

out=$(node cipher.js --type=rot13 --mode=encode --message="S O S!@#$%^&*()\r\n\t");
equal "Special characters filtering" "F B F!@#$%^&*()\e\a\g";

out=$(node cipher.js --type=rot13 --mode=encode --message="ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 abcdefghijklmnopqrstuvwxyz");
equal "Test of full scope of supported language" "NOPQRSTUVWXYZABCDEFGHIJKLM 0123456789 nopqrstuvwxyzabcdefghijklm";



################
scenario "ROT13 decode"

out=$(node cipher.js --type=rot13 --mode=decode --message="Unyyb jbeyq!!!");
equal "Basic test" "Hallo world!!!";


echo -e "\n PASS: $(( $counter * $c_pass ))%  FAILED: $(( $counter * $c_fail ))%  from $counter tests.\n"
