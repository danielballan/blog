---
layout: post
title: Couples' Dreidel
image: 800px-Colorful_dreidels2.jpg
wordpress_id: 1667
wordpress_url: http://www.danallan.com/?p=1667
categories: projects computing
tags: []
---

During my first-ever game of dreidel this week, we agreed on a friendly variation in the rules. When someone was about to run out of chocolate coins and be knocked out of the game, couples could rescue each other with a "loan." Eventually we put a stop to that, thinking that all this rescuing was making the game drag on.

For a definitive answer, I wrote a short Python script that simulates thousands of dreidel games, tallying how many turns are played. As it turns out, we were wrong. If you allow couples to win a joint victory, then games that allow rescuing actually end much faster. Couples defeat other couples and other single players faster than single players defeat each other, even though all players — coupled or not — still take separate turns. If you insist on having only one winner, making the couple break their alliance in the end and play out the game, the games get a little longer but the effect it not large. (I originally published a different conclusion about this last scenario.)
<pre>Simulating 10,000 6-player games. Each player start with 5 coins.No couples: 112 minutesOne couple: 101 minutesTwo couples: 84 minutesThree couples: 68 minutesDisallow joint victories:One couple: 114 minutesTwo couples: 121 minutesThree couples: 127 minutes</pre>
The statistical error of these results is about one minute. [See the code.](#)
<div id="example" class="more"><pre class="brush: python">#!/usr/bin/python# How long does a game of dreidel take?# How does that change when couples form &quot;alliances&quot; and help each other out?import randomfrom numpy import average, round, stddef pay(i, coins, couples):    &quot;Pay what is owed, or have your partner pay, or lose the game.&quot;    if coins[i] &gt; 0:        # Player can pay.        coins[i] -= 1        paid = True    elif couples[i]:        # Player has a partner.        if coins[couples[i]] &gt; 0:            # That partner can afford a loan.            coins[couples[i]] -= 1            paid = True        else:            coins[i] = None # Player is out of the game.            paid = False    else:            coins[i] = None # Player is out of the game.            paid = False    return coins, paiddef play_round(coins, couples, turn_counter, next_player):    &quot;Simulate one round of the game, and count turns.&quot;    # Ante up.    pot = 0    for i in range(len(coins)):        if coins[i] is not None:            coins, paid = pay(i, coins, couples)            if (paid):                pot += 1    # Take turns.    while pot &gt; 0:        # List players in order, starting with whoever&#039;s turn it is.        for i in map(lambda x: x % len(coins),                     range(next_player, next_player+len(coins))):            if coins[i] is None:                continue # Player is already out of the game.            roll = random.choice([&#039;nun&#039;, &#039;gimmel&#039;, &#039;hey&#039;, &#039;shin&#039;])            if roll is &#039;gimmel&#039;:                coins[i] += pot                pot = 0            elif roll is &#039;hey&#039;:                coins[i] += pot/2                pot = pot - pot/2            elif roll is &#039;shin&#039;:                coins, paid = pay(i, coins, couples)                if paid:                    pot += 1            turn_counter += 1            if pot is 0:                next_player = i+1                break        return coins, turn_counter, next_playerdef game(number_of_players, starting_money, couples, allow_joint_victory=True):    &quot;Simulate a game, and count turns.&quot;    coins = number_of_players*[starting_money]    turn_counter = 0    next_player = 0    # In the function call, couples may be specified as an     # explicit list with a seating arrangement.    # Alternatively, the call may simply give the NUBMER of     # couples. They will be seated beside each other.    if type(couples) is not list:        number_of_couples = couples        couples = number_of_players*[None]        for i in range(number_of_couples):            couples[2*i]=2*i+1            couples[2*i+1]=2*i    while True:        # Check whether game has ended.        winners = [i for i, c in enumerate(coins) if c is not None]        if (len(winners) is 1): break # One winner.        if (len(winners) is 2 and            winners[0] == couples[winners[1]]):                if (allow_joint_victory is True):                    break # Joint win.                else:                    # End the alliance and play it out.                    couples = number_of_players*[None]        coins, turn_counter, next_player = play_round(            coins, couples, turn_counter, next_player)    return turn_counterdef simulate_games(N, number_of_players, starting_money,                    number_of_couples, allow_joint_victory=True):    &quot;Return average game duration of N simulated games.&quot;    TURNS_PER_MIN = 5 # estimated turns per minute, to interpret result    outcomes = [game(number_of_players, starting_money,                          number_of_couples, allow_joint_victory) for x in \                         range(N)]    value = int(round(average(outcomes)/TURNS_PER_MIN))    error = int(round(std(outcomes)/TURNS_PER_MIN))    return str(value) + &#039; +/- &#039; + str(error) + &#039; minutes&#039;def main():    &quot;&quot;&quot;Some experiments, a default example using    the functions above.&quot;&quot;&quot;    TRIALS = 100    N_PLAYERS = 6    MONEY = 5    print &#039;Simulating 10,000 6-player games. Each player starts with 5 coins.&#039;    print &#039;No couples:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 0)    print &#039;One couple:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 1)    print &#039;Two couples:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 2)    print &#039;Three couples:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 3)    print &#039;Disallow joint victories:&#039;    print &#039;One couple:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 1, False)    print &#039;Two couples:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 2, False)    print &#039;Three couples:&#039;, simulate_games(TRIALS, N_PLAYERS, MONEY, 3, False)    print &#039;One couple, seated one seat apart:&#039;, simulate_games(TRIALS, N_PLAYERS,         MONEY, [2, None, 0, None, None, None])    print &#039;One couple, seated two seats apart:&#039;, simulate_games(TRIALS, N_PLAYERS,         MONEY, [3, None, None,  0, None, None])    print &#039;One couple, seated one seat apart:&#039;, simulate_games(        TRIALS, N_PLAYERS, MONEY, [2, None, 0, None, None, None])    print &#039;One couple, seated two seats apart:&#039;, simulate_games(        TRIALS, N_PLAYERS, MONEY, [3, None, None,  0, None, None])    print &#039;Disallow joint victories:&#039;    print &#039;One couple, seated one seat apart:&#039;, simulate_games(        TRIALS, N_PLAYERS, MONEY, [2, None, 0, None, None, None], False)    print &#039;One couple, seated two seats apart:&#039;, simulate_games(        TRIALS, N_PLAYERS, MONEY, [3, None, None,  0, None, None], False)if __name__== &#039;__main__&#039;:    main()</pre>
[Hide the code.](#)
</div>