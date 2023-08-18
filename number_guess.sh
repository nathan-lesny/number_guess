#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUM=$((1 + $RANDOM % 1000))
re='^[0-9]+$'
echo $RANDOM_NUM
echo "Enter your username:"
read USERNAME

USERNAME_EXISTS="$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")"

if [[ -z $USERNAME_EXISTS ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  CREATE_USER="$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")"
else
  USER_ID="$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")"
  NUM_GAMES="$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")"
  BEST_GAME="$($PSQL "SELECT MIN(guesses) FROM games GROUP BY user_id HAVING user_id=$USER_ID")"
  echo -e "\nWelcome back, $USERNAME! You have played $NUM_GAMES, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESS_NUM=1
if ! [[ $GUESS =~ $re ]] ; then
echo "That is not an integer, guess again:"
read GUESS
fi

while [ $GUESS != $RANDOM_NUM ]
do
  if ! [[ $GUESS =~ $re ]] ; then
echo "That is not an integer, guess again:"
read GUESS
fi
  if [[ $GUESS > $RANDOM_NUM ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  GUESS_NUM=$((GUESS_NUM+1))
done


USER_ID="$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")"
ADD_GAME="$($PSQL "INSERT INTO games(guesses, user_id) VALUES($GUESS_NUM, $USER_ID)")"

echo -e "\nYou guessed it in $GUESS_NUM tries, the secret number was $RANDOM_NUM. Nice job!"
