# markov

a druid skript for monome crow that generates two sequences based on markov chains.


## transformation matrices

there are four transformation matrices at the top of the script. they are probability matrices that, given an event, determine the probability of the following event. see [wikipedia](https://en.wikipedia.org/wiki/Examples_of_Markov_chains) for more on this.

there are two cv matrices that determine if the next note will be the same (column 1), go up (column 2) or go down (column 3), depending on the event that occurred before: row 1 of the matrix contains the probabilites of the next events if previously the note did not change, row 2 contains the probabilities if previously the note went up, row 3 contains the probabilities if previously the note went down.

the two beat matrices contain the probabilities for beat (column 1) and pause (column 2), depending if previously a beat (row 1) or a pause (row 2) occurred.


## usage

adjust the probability matrices to your liking. just keep in mind that every row has to sum up to 1.0.

if you want to use an external clock (e.g. from your modular), plug it into input 1 and the sequences should start.

if you don't use an external clock use

```
start(bpm, number_of_steps)
```

in druid to start the sequencer, where _bpm_ is the speed of the sequencer and _number_of_steps_ is the number of steps the sequencer should run. use -1 as the number of steps to start an endless sequence.

so, for example
```
start(140, 100)
```
will start a sequence of 100 steps with a bpm of 140.

```
start(90, -1)
```

will start an endless sequence at 90 bpm.

use
```
set_bpm(bpm)
```
to change the speed of the sequence while it is running.

use
```
stop()
```

to stop the sequence.


## more settings

there are more setting in the head of the script to explore: add your own scales to CONFIG.SCALES, change the scale that is being used to quantize notes, change the initial states, set the initial octave and the octave range to operate in.


## crow inputs/outputs

* input 1: clock
* input 2: (not in use)
* output 1: cv1
* output 2: trigger 1
* output 3: cv2
* output 4: trigger 2
