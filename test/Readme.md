# Explanation of our testing

## F1 lights testing

To test our program, we ran it using the do it file that is in the rtl, base folder. Our expected outcome is for each light to come on incrementally, when the trigger is pressed, then a random delay when they're all lit before the lights then turning off.



https://user-images.githubusercontent.com/116260803/207304050-5d9542f9-8b06-49fd-bb07-cabc23c90fe9.mp4

(NOTE: we used the website veed.io to compress our video so that we could upload it to github)

As expected, the F1 lights program works and we can clearly see the random delay implemented as there are two different delays in the two cycles we ran.


## Reference Program testing

To test the reference program, we had to specify, in accordance to the data map provided in the reference program repo, where we start writing to, we did this in the following way:
``` verilog
  $readmemh("DataMemory.mem", RAM, 32'h10000);
```
This specifies that the first address we are writing to is 0x00010000
